class CreateReportLearnerActivity < ActiveRecord::Migration
  def self.up
    create_table :report_learner_activity do |t|
      t.integer  :learner_id
      t.integer  :activity_id
      t.float   :complete_percent
    end
    add_index :report_learner_activity, :learner_id
    add_index :report_learner_activity, :activity_id
    
    
    large_sql_query = <<-SQLQUERY
      
      
      DROP TEMPORARY TABLE IF EXISTS temp_report_learner_activity;
      DROP TEMPORARY TABLE IF EXISTS temp_report_learner_activity_embeddables;
      DROP TEMPORARY TABLE IF EXISTS temp_report_learner_activity_embeddables_temp_copy;
      
      
      
      CREATE TEMPORARY TABLE temp_report_learner_activity
      (
        id INT(11) AUTO_INCREMENT PRIMARY KEY,
        learner_id INT(11),
        activity_id INT(11),
        saveable_answerables INT(11),
        saveable_answered INT(11),
        complete_percent FLOAT
      );
      
      
      CREATE TEMPORARY TABLE temp_report_learner_activity_embeddables
      (
        id INT(11) AUTO_INCREMENT PRIMARY KEY,
        learner_id INT(11),
        activity_id INT(11),
        embeddable_id INT(11),
        embeddable_type VARCHAR(255)
      );
      
      
      CREATE TEMPORARY TABLE temp_report_learner_activity_embeddables_temp_copy
      (
        id INT(11) AUTO_INCREMENT PRIMARY KEY,
        learner_id INT(11),
        activity_id INT(11),
        embeddable_id INT(11),
        embeddable_type VARCHAR(255)
      );
      
      
      INSERT INTO temp_report_learner_activity
        (learner_id, activity_id, saveable_answerables, saveable_answered)
      SELECT A.learner_id, C.id, 0, 0
      FROM report_learners A
      INNER JOIN activities C
        ON A.runnable_id = C.investigation_id
        AND A.runnable_type = 'investigation';
      
      
      INSERT INTO temp_report_learner_activity_embeddables (learner_id, activity_id, embeddable_id, embeddable_type)
      SELECT A.learner_id, D.activity_id, F.embeddable_id, F.embeddable_type
      FROM temp_report_learner_activity A
      INNER JOIN sections D
        ON A.activity_id = D.activity_id
      INNER JOIN pages E
        ON D.id = E.section_id
      INNER JOIN page_elements F
        ON E.id = F.page_id
        AND F.embeddable_type IN ('Embeddable::MultipleChoice', 'Embeddable::ImageQuestion', 'Embeddable::OpenResponse', 'Embeddable::InnerPage');
      
      INSERT INTO temp_report_learner_activity_embeddables_temp_copy (learner_id, activity_id, embeddable_id, embeddable_type)
      SELECT learner_id, activity_id, embeddable_id, embeddable_type
      FROM temp_report_learner_activity_embeddables;
      
      
      INSERT INTO temp_report_learner_activity_embeddables (learner_id, activity_id, embeddable_id, embeddable_type)
      SELECT A.learner_id, A.activity_id, D.embeddable_id, D.embeddable_type
      FROM temp_report_learner_activity_embeddables_temp_copy A
      INNER JOIN embeddable_inner_pages B
        ON A.embeddable_id = B.id
        AND A.embeddable_type = 'Embeddable::InnerPage'
      INNER JOIN embeddable_inner_page_pages C
        ON B.id = C.inner_page_id
      INNER JOIN page_elements D
        ON C.page_id = D.page_id
        AND D.embeddable_type IN ('Embeddable::MultipleChoice', 'Embeddable::ImageQuestion', 'Embeddable::OpenResponse');
      
      DROP TEMPORARY TABLE IF EXISTS temp_report_learner_activity_embeddables_temp_copy;
      
      UPDATE temp_report_learner_activity A
      INNER JOIN (
              SELECT learner_id, activity_id, COUNT(id) saveable_answerables
              FROM temp_report_learner_activity_embeddables
              WHERE embeddable_type IN ('Embeddable::MultipleChoice', 'Embeddable::ImageQuestion', 'Embeddable::OpenResponse')
              GROUP BY learner_id, activity_id
            ) B
        ON A.learner_id = B.learner_id
        AND A.activity_id = B.activity_id
        SET A.saveable_answerables = B.saveable_answerables;
      
      
      UPDATE temp_report_learner_activity X
      INNER JOIN (
              SELECT A.learner_id, A.activity_id, count(B.id) saveable_answered
              FROM temp_report_learner_activity_embeddables A
              INNER JOIN saveable_multiple_choices B
                ON A.embeddable_id = B.multiple_choice_id
                AND A.learner_id = B.learner_id -- we are not joining on activity_id assuming an embeddable will not be part of more than one activity
                AND A.embeddable_type = 'Embeddable::MultipleChoice'
              GROUP BY A.learner_id, A.activity_id
            ) Y
        ON X.learner_id = Y.learner_id
        AND X.activity_id = Y.activity_id
      SET X.saveable_answered = X.saveable_answered + Y.saveable_answered;
      
      
      UPDATE temp_report_learner_activity X
      INNER JOIN (
              SELECT A.learner_id, A.activity_id, count(B.id) saveable_answered
              FROM temp_report_learner_activity_embeddables A
              INNER JOIN saveable_image_questions B
                ON A.embeddable_id = B.image_question_id
                AND A.learner_id = B.learner_id -- we are not joining on activity_id assuming an embeddable will not be part of more than one activity
                AND A.embeddable_type = 'Embeddable::ImageQuestion'
              GROUP BY A.learner_id, A.activity_id
            ) Y
        ON X.learner_id = Y.learner_id
        AND X.activity_id = Y.activity_id
      SET X.saveable_answered = X.saveable_answered + Y.saveable_answered;
      
      
      UPDATE temp_report_learner_activity X
      INNER JOIN (
              SELECT A.learner_id, A.activity_id, count(B.id) saveable_answered
              FROM temp_report_learner_activity_embeddables A
              INNER JOIN saveable_open_responses B
                ON A.embeddable_id = B.open_response_id
                AND A.learner_id = B.learner_id -- we are not joining on activity_id assuming an embeddable will not be part of more than one activity
                AND A.embeddable_type = 'Embeddable::OpenResponse'
              GROUP BY A.learner_id, A.activity_id
            ) Y
        ON X.learner_id = Y.learner_id
        AND X.activity_id = Y.activity_id
      SET X.saveable_answered = X.saveable_answered + Y.saveable_answered;
      
      
      
      DROP TEMPORARY TABLE IF EXISTS temp_report_learner_activity_embeddables;
      
      
      UPDATE temp_report_learner_activity SET
        complete_percent = (saveable_answered * 100) / saveable_answerables;
        
      
      
      
      INSERT INTO report_learner_activity 
      (learner_id, activity_id, complete_percent)
      SELECT learner_id, activity_id, complete_percent
      FROM temp_report_learner_activity A
      LEFT OUTER JOIN report_learner_activity B
        ON A.learner_id = B.learner_id
        AND A.activity_id = B.activity_id
      WHERE B.id IS NULL;
      
      UPDATE report_learner_activity A
      INNER JOIN temp_report_learner_activity B
        ON A.learner_id = B.learner_id
        AND A.activity_id = B.activity_id
      SET A.complete_percent = B.complete_percent;
      
      
      DROP TEMPORARY TABLE IF EXISTS temp_report_learner_activity;
    SQLQUERY
    
    
    sql_queries = large_sql_query.split(';').map{|q| q.strip}
    
    sql_queries.each do |sql_query|
      unless sql_query =~ /\S+/
        next
      end
      execute sql_query
    end
    
  end

  def self.down
    remove_index :report_learner_activity, :learner_id
    remove_index :report_learner_activity, :activity_id
    
    drop_table :report_learner_activity
  end
end
