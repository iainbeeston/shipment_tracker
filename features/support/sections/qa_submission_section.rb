module Sections
  class QaSubmissionSection
    include Virtus.value_object

    values do
      attribute :name, String
      attribute :status, String
    end

    def self.from_element(qa_submission_element)
      values = qa_submission_element.all('td').map(&:text).to_a
      new(
        name:   values.fetch(0),
        status: values.fetch(1),
      )
    end
  end
end
