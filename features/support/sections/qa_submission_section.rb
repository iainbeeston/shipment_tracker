module Sections
  class QaSubmissionSection
    include Virtus.value_object

    values do
      attribute :email, String
      attribute :comment, String
    end

    def self.from_element(qa_submission_element)
      new(
        email: qa_submission_element.find('.qa-email').text,
        comment: qa_submission_element.find('.qa-comment').text,
      )
    end
  end
end
