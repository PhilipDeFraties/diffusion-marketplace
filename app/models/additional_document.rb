class AdditionalDocument < ApplicationRecord
  has_attached_file :attachment
  do_not_validate_attachment_file_type :attachment
  belongs_to :practice
end
