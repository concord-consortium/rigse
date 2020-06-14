class API::V1::AnswersController < API::APIController

  require 'yaml'

  public

  # GET api/v1/answer/student_answers?teacher_id=:teacher_id
  def student_answers
    authorize [:api, :v1, :answer]
    teacher_ids = params.require(:teacher_id)
    if !teacher_ids.kind_of?(Array)
      teacher_ids = [teacher_ids]
    end
    sanitized_ids = teacher_ids.map { |id| Integer(id) }

    # fill the json with all the students
    json = {:teachers => {}}
    get_teacher_activities_and_students(sanitized_ids).each(:as => :hash) do |info|
      teacher = json[:teachers][info["teacher_id"]] ||= {:first_name => info["teacher_first_name"], :last_name => info["teacher_last_name"], :activities => {}}
      offering = teacher[:activities][info["activity_id"]] ||= {:name => info["activity_name"], :classes => {}}
      clazz = offering[:classes][info["clazz_id"]] ||= {:name => info["class_name"], :students => {}}
      clazz[:students][info["student_id"]] = {
        :first_name => info["student_first_name"],
        :last_name => info["student_last_name"],
        :found_answers => false
      }
    end

    # get the prompts
    prompts = get_prompts(sanitized_ids)
    Rails.logger.info prompts.to_json

    # fill in the answers
    get_student_answers(sanitized_ids).each(:as => :hash) do |answer|
      teacher = json[:teachers][answer["teacher_id"]]
      if teacher
        offering = teacher[:activities][answer["activity_id"]]
        if offering
          clazz = offering[:classes][answer["clazz_id"]]
          if clazz
            student = clazz[:students][answer["student_id"]]
            if student
              student[:found_answers] = true
              student[:questions] = convert_answers_to_array(prompts, YAML.load(answer["answers"]))
            end
          end
        end
      end
    end

    render json: json.to_json
  end

  private

  def get_teacher_activities_and_students(teacher_ids)
    query = ActiveRecord::Base.connection.execute "
      SELECT
      pt.id AS teacher_id, u1.first_name AS teacher_first_name, u1.last_name AS teacher_last_name, po.runnable_id AS activity_id, ea.name AS activity_name, po.clazz_id, pc.name AS class_name, ps.id AS student_id, u2.first_name AS student_first_name, u2.last_name AS student_last_name
      FROM portal_offerings po, portal_clazzes pc, portal_teacher_clazzes ptc, portal_teachers pt, users u1, portal_student_clazzes psc, portal_students ps, users u2, external_activities ea
      WHERE pc.id = po.clazz_id AND pc.id = ptc.clazz_id AND ptc.teacher_id = pt.id AND pt.user_id = u1.id AND psc.clazz_id = pc.id AND psc.student_id = ps.id AND u2.id = ps.user_id AND ea.id = po.runnable_id AND pt.id IN (#{teacher_ids.join(',')})"
  end

  def get_student_answers(teacher_ids)
    query = ActiveRecord::Base.connection.execute "
      SELECT ptc.teacher_id, rl.runnable_id AS activity_id, rl.class_id as clazz_id, rl.student_id, rl.answers
      FROM portal_teacher_clazzes ptc
      LEFT JOIN report_learners rl ON rl.class_id = ptc.clazz_id
      WHERE ptc.teacher_id IN (#{teacher_ids.join(',')})
    "
  end

  def get_prompts(teacher_ids)
    prompts = {}
    query = ActiveRecord::Base.connection.execute "
      SELECT
        DISTINCT pe.embeddable_id AS id, pe.embeddable_type AS `type`, eor.prompt AS open_response_prompt, emc.prompt AS multiple_choice_prompt
      FROM
        portal_teacher_clazzes ptc, portal_offerings po, external_activities ea, sections s, pages p, page_elements pe
        LEFT JOIN embeddable_open_responses eor ON (pe.embeddable_id = eor.id AND pe.embeddable_type = 'Embeddable::OpenResponse')
        LEFT JOIN embeddable_multiple_choices emc ON (pe.embeddable_id = emc.id AND pe.embeddable_type = 'Embeddable::MultipleChoice')
      WHERE
        po.clazz_id = ptc.clazz_id AND
        po.runnable_id = ea.id AND
        ea.template_id = s.activity_id AND
        p.section_id = s.id AND
        pe.page_id = p.id AND
        ptc.teacher_id IN (#{teacher_ids.join(',')})"
    query.each(:as => :hash) do |info|
      key = [info["type"], info["id"]].join('|')
      if info["type"] == "Embeddable::OpenResponse"
        prompts[key] = info["open_response_prompt"]
      elsif info["type"] == "Embeddable::MultipleChoice"
        prompts[key] = info["multiple_choice_prompt"]
      else
        prompts[key] = ""
      end
    end
    prompts
  end

  def convert_answers_to_array(prompts, answerHash)
    answers = []
    answerHash.each do |key, value|
      keyParts = key.split("|")
      value[:type] = keyParts[0]
      value[:id] = keyParts[1]
      value[:prompt] = prompts.has_key?(key) ? strip_tags(prompts[key]) : "N/A"
      answers.push value
    end
    answers
  end

  def strip_tags(s)
    ActionController::Base.helpers.strip_tags s
  end

end
