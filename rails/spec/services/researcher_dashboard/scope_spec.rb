require 'spec_helper'

RSpec.describe ResearcherDashboard::Scope do
  let(:project)  { FactoryBot.create(:project) }
  let(:cohort)   { FactoryBot.create(:admin_cohort, name: 'Cohort A', project: project) }
  let(:teacher)  { FactoryBot.create(:portal_teacher, cohorts: [cohort]) }
  let(:clazz)    { FactoryBot.create(:portal_clazz, teachers: [teacher]) }
  let(:ap_tool)  { FactoryBot.create(:ap_tool) }
  let(:activity) { FactoryBot.create(:external_activity, name: 'Moth 1.2', url: 'https://ap.example/?activity=1', tool: ap_tool) }
  let(:scope)    { described_class.new(clazz) }

  def offer(runnable, attrs = {})
    FactoryBot.create(:portal_offering, { clazz: clazz, runnable: runnable }.merge(attrs))
  end

  # A fresh object, so memoized assignments do not hide a change.
  def fingerprint
    described_class.new(clazz.reload).fingerprint
  end

  describe "#assignments" do
    it "lists each external-activity offering in position order" do
      second = offer(FactoryBot.create(:external_activity, name: 'Second'), position: 2)
      first = offer(activity, position: 1)
      expect(scope.assignments).to eq([
        { offering_id: first.id, runnable_id: activity.id, name: 'Moth 1.2', url: 'https://ap.example/?activity=1', tool: 'Activity Player' },
        { offering_id: second.id, runnable_id: second.runnable_id, name: 'Second', url: 'http://external.activitiies.org/123', tool: 'LARA' }
      ])
    end

    it "returns the stored URL exactly, not ExternalActivity#url" do
      activity.update_column(:url, 'HTTPS://Ap.Example:443/?activity=1')
      offer(activity)
      expect(activity.reload.url).to eq('https://Ap.Example/?activity=1')
      expect(scope.assignments.first[:url]).to eq('HTTPS://Ap.Example:443/?activity=1')
    end

    it "gives a nil tool for an activity with no tool" do
      activity.update_column(:tool_id, nil)
      offer(activity)
      expect(scope.assignments.first[:tool]).to be_nil
    end

    it "includes inactive offerings" do
      offer(activity, active: false)
      expect(scope.assignments.size).to eq(1)
    end

    it "skips an offering of any other runnable type without raising" do
      offer(activity)
      offer(FactoryBot.create(:external_activity)).update_column(:runnable_type, 'Investigation')
      expect(scope.assignments.map { |a| a[:runnable_id] }).to eq([activity.id])
    end

    it "returns an empty URL and a nil name as they are" do
      activity.update_columns(url: '', name: nil)
      offer(activity)
      expect(scope.assignments.first).to include(url: '', name: nil)
    end
  end

  describe "#run_assignments" do
    it "is the assignments without tool" do
      offer(activity)
      expect(scope.run_assignments).to eq(scope.assignments.map { |a| a.except(:tool) })
      expect(scope.run_assignments.first).not_to have_key(:tool)
    end
  end

  describe "#fingerprint" do
    it "is v1: and a SHA-256, stable on recomputation" do
      offer(activity)
      expect(fingerprint).to match(/\Av1:\h{64}\z/)
      expect(fingerprint.length).to eq(67)
      expect(fingerprint).to eq(fingerprint)
    end

    it "changes when the assignment set changes" do
      seen = [fingerprint]
      first = offer(activity)
      seen << fingerprint
      offer(activity)
      seen << fingerprint
      activity.update_column(:url, 'https://ap.example/?activity=2')
      seen << fingerprint
      first.destroy
      seen << fingerprint
      expect(seen.uniq.size).to eq(5)
    end

    it "does not change when offerings are reordered" do
      a = offer(activity, position: 1)
      b = offer(FactoryBot.create(:external_activity), position: 2)
      before = fingerprint
      a.update_column(:position, 3)
      b.update_column(:position, 0)
      expect(fingerprint).to eq(before)
    end
  end

  describe "#derive_profile_body" do
    def with_urls(urls)
      allow(scope).to receive(:assignments).and_return(
        urls.each_with_index.map { |url, i| { offering_id: i + 1, runnable_id: i + 1, name: 'x', url: url, tool: nil } }
      )
    end

    it "carries the class hash, the fingerprint and the distinct non-empty URLs sorted" do
      offer(FactoryBot.create(:external_activity, url: 'https://b.example/'))
      offer(activity)
      offer(activity)
      offer(FactoryBot.create(:external_activity)).runnable.update_column(:url, '')
      expect(scope.derive_profile_body).to eq(
        class_hash: clazz.class_hash,
        assignment_fingerprint: scope.fingerprint,
        assignment_urls: ['https://ap.example/?activity=1', 'https://b.example/']
      )
    end

    it "leaves out a URL longer than 2,048 characters while the fingerprint still covers it" do
      long = 'https://a.example/' + ('x' * (2049 - 18))
      expect(long.length).to eq(2049)
      offer(activity)
      without = fingerprint
      offer(FactoryBot.create(:external_activity)).runnable.update_column(:url, long)
      body = described_class.new(clazz.reload).derive_profile_body
      expect(body[:assignment_urls]).to eq(['https://ap.example/?activity=1'])
      expect(body[:assignment_fingerprint]).not_to eq(without)
    end

    it "keeps a URL of exactly 2,048 characters" do
      url = 'https://a.example/' + ('x' * (2048 - 18))
      expect(url.length).to eq(2048)
      with_urls([url])
      expect(scope.derive_profile_body[:assignment_urls]).to eq([url])
    end

    it "accepts 500 distinct URLs" do
      with_urls((1..500).map { |i| "https://a.example/#{i}" })
      expect(scope.derive_profile_body[:assignment_urls].size).to eq(500)
    end

    it "refuses 501 distinct URLs with a 422" do
      with_urls((1..501).map { |i| "https://a.example/#{i}" })
      expect { scope.derive_profile_body }.to raise_error(ResearcherDashboard::Refusal) { |e|
        expect(e.status).to eq(422)
        expect(e.message).to match(/501 distinct assignment URLs/)
      }
    end

    it "refuses a body over 256 KiB with a 422" do
      with_urls((1..200).map { |i| "https://a.example/#{i}/" + ('x' * 1400) })
      expect { scope.derive_profile_body }.to raise_error(ResearcherDashboard::Refusal) { |e|
        expect(e.status).to eq(422)
        expect(e.message).to match(/256 KiB/)
      }
    end
  end

  describe "teachers, cohorts and projects" do
    let(:other_project) { FactoryBot.create(:project) }
    let(:second_teacher) {
      FactoryBot.create(:portal_teacher, cohorts: [
        cohort,
        FactoryBot.create(:admin_cohort, name: 'Cohort B', project: other_project),
        FactoryBot.create(:admin_cohort, name: 'No project')
      ])
    }
    let(:clazz) { FactoryBot.create(:portal_clazz, teachers: [teacher, second_teacher]) }

    it "lists each teacher by user id and name" do
      expect(scope.teachers).to eq([teacher, second_teacher].map { |t|
        { id: t.user_id, name: "#{t.user.first_name} #{t.user.last_name}" }
      })
    end

    it "lists each teacher's cohorts once" do
      expect(scope.cohorts.map(&:name)).to eq(['Cohort A', 'Cohort B', 'No project'])
    end

    it "lists the cohorts' projects sorted, without a nil" do
      expect(scope.project_ids).to eq([project.id, other_project.id].sort)
    end

    it "ignores cohorts of teachers of other classes" do
      FactoryBot.create(:portal_clazz, teachers: [FactoryBot.create(:portal_teacher, cohorts: [FactoryBot.create(:admin_cohort, name: 'Elsewhere')])])
      expect(scope.cohorts.map(&:name)).not_to include('Elsewhere')
    end
  end
end
