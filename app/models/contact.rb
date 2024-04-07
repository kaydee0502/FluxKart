class Contact < ApplicationRecord
  enum linkPrecedence: [:primary, :secondary]

  def self.create_record(phoneNumber, email, linkPrecedence, linkedId)
    Contact.create(
      email: email,
      phoneNumber: phoneNumber,
      linkPrecedence: linkPrecedence,
      linkedId: linkedId
    )
  end
end
