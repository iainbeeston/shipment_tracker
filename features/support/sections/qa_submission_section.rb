module Sections
  class QaSubmissionSection
    include Virtus.value_object

    values do
      attribute :name, String
    end

    def self.from_element(qa_submission_element)
      new(
        name:   qa_submission_element.find('.qa-name').text,
      )
    end
  end
end
