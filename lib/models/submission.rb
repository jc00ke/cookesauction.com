class Submission
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name
    field :email
    field :comment

    validates_presence_of :name, :email, :comment
    validates_length_of :comment, :maximum => 250
    validates_format_of :email, :with => EMAIL_REGEXP
end
