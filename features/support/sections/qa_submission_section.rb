module Sections
  class QaSubmissionSection
    include Virtus.value_object

    values do
      attribute :status, String
      attribute :email, String
      attribute :comment, String
    end

    def self.from_element(qa_submission_element)
      status_classes = {
        'panel-success' => 'success',
        'panel-danger'  => 'danger',
        'panel-warning' => 'n/a',
      }

      classes = qa_submission_element[:class].split
      status_class = (classes & status_classes.keys).first

      new(
        status: status_classes.fetch(status_class),
        email: qa_submission_element.find('.qa-email').text,
        comment: qa_submission_element.find('.qa-comment').text,
      )
    end
  end
end
