class Captain::Capabilities::Billing::SelectCurrency < Captain::Capabilities::Base
  def call(currency:)
    authorize!(account, :select_billing_currency?)
    return 'Billing currency selection is only available on Chatwoot Cloud' unless ChatwootApp.chatwoot_cloud?
    return I18n.t('errors.billing.currency_locked') if currency_locked?
    return I18n.t('errors.billing.invalid_currency') unless account.billing_currency_selection_required?

    normalized_currency = Enterprise::Billing::Currencies.normalize(currency)
    return I18n.t('errors.billing.invalid_currency') unless Enterprise::Billing::Currencies.supported?(normalized_currency)

    account.update!(custom_attributes: account.custom_attributes.merge('billing_currency' => normalized_currency))
  rescue UnauthorizedError
    handle_unauthorized
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e.record)
  end

  private

  def currency_locked?
    account.custom_attributes['stripe_customer_id'].present? || account.custom_attributes['is_creating_customer'].present?
  end
end
