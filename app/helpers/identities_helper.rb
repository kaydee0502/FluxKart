module IdentitiesHelper
  def reconcile_contacts(contact1, contact2)
    # Return if both contacts are aready reconciled or same
    return if [
      contact1.id == contact2.linkedId,
      contact1.linkedId == contact2.id,
      contact1.id == contact2.id
    ].any?

    primary1 = find_primary_contact(contact1)
    primary2 = find_primary_contact(contact2)

    return if primary1 == primary2

    older_record = [primary1, primary2].min_by { |record| record.created_at }
    newer_record = [primary1, primary2] - [older_record]

    # Older record will remain the parent
    # And newer primary record will conver to secondaryß
    Contact.where(linkedId: newer_record.last.id).update_all(linkedId: older_record.id)
    newer_record.last.update(linkPrecedence: 'secondary', linkedId: older_record.id)
  end

  def find_primary_contact(contact)
    return contact if contact.primary?

    Contact.find_by_id(contact.linkedId)
  end
end
