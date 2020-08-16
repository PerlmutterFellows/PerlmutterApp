require 'browser'
module StaticPagesHelper
  def contact_configured?
    I18n.t('config.contact').kind_of?(Hash) && I18n.t('config.contact').count != 0
  end

  def faq_configured?
    I18n.t('faq').kind_of?(Array) && I18n.t('faq').count != 0
  end

  def form_configured?
    I18n.t('form').kind_of?(Array) && I18n.t('form').count != 0
  end

  def mobile?(browser)
    [browser.platform.android?,
     browser.platform.blackberry?,
     browser.platform.ios?,
     browser.platform.windows_mobile?,
     browser.platform.windows_phone?].any?
  end

end
