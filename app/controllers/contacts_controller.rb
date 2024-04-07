class ContactsController < ApplicationController
  include IdentitiesHelper
  before_action :set_records, only: [:identities]
  before_action :prepare_identities, only: [:identities], if: :is_primary_unset?

  def identities
    if @primary.blank?
      @primary = Contact.create!(
        phoneNumber: params[:phoneNumber],
        email: params[:email],
        linkPrecedence: 'primary'
      )
    end

    all_relevant_contacts = Contact.where(linkedId: @primary.id)
    response = {
      "contact":{
        "primaryContatctId": @primary.id,
        "emails": ([@primary.email] + all_relevant_contacts.pluck(:email)).compact.uniq,
        "phoneNumbers":([@primary.phoneNumber] + all_relevant_contacts.pluck(:phoneNumber)).compact.uniq,
        "secondaryContactIds": all_relevant_contacts.pluck(:id)
      }
    }

    render json: response
  end

  private

  def set_records
    # Check if record with current params combination exists
    single_contact = Contact.where(email: params[:email], phoneNumber: params[:phoneNumber]).last
    if single_contact.present?
      @primary = find_primary_contact(single_contact)
      return
    end

    @contact1 = Contact.find_by_email(params[:email])
    @contact2 = Contact.find_by_phoneNumber(params[:phoneNumber])
  end

  def prepare_identities
    # If both contacts are blank, then no preprocesing is required
    return if @contact1.blank? && @contact2.blank?

    # Call helper method to reconcile records if present
    if @contact1.present? && @contact2.present?
      reconcile_contacts(@contact1, @contact2)

      # After reconcilation, reload both records as they are now stale
      @contact1.reload; @contact2.reload
      primaryId = @contact1.linkedId || @contact1.id
    elsif @contact1.blank? || @contact2.blank?
      # If either of record present, then create a secondary record with current params
      contact = [@contact1, @contact2].compact.last
      primaryId = contact.linkedId || contact.id
    end

    # create a secondary record with current params
    Contact.create_record(
      params[:phoneNumber],
      params[:email],
      'secondary',
      primaryId
    )

    set_primary(primaryId)
  end

  def set_primary(id)
    @primary = Contact.find_by_id(id)
  end

  def is_primary_unset?
    @primary.blank?
  end
end
