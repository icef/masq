require 'digest/sha1'

module Masq
  class Account < ActiveRecord::Base
    has_many :personas, :dependent => :delete_all, :order => 'id ASC'
    has_many :sites, :dependent => :destroy
    belongs_to :public_persona, :class_name => "Persona"

    validates_presence_of :login
    validates_length_of :login, :within => 3..254
    validates_uniqueness_of :login, :case_sensitive => false
    validates_format_of :login, :with => /^[A-Za-z0-9_@.-]+$/
    validates_presence_of :email
    validates_uniqueness_of :email, :case_sensitive => false
    validates_format_of :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
    validates_presence_of :password, :if => :password_required?
    validates_presence_of :password_confirmation, :if => :password_required?
    validates_length_of :password, :within => 6..40, :if => :password_required?
    validates_confirmation_of :password, :if => :password_required?
    # check `rake routes' for whether this list is still complete when routes are changed
    validates_exclusion_of :login, :in => %w[account session password help safe-login forgot_password reset_password login logout server consumer]

    before_save   :encrypt_password
    after_save    :deliver_forgot_password

    attr_accessible :login, :email, :password, :password_confirmation, :public_persona_id, :yubikey_mandatory
    attr_accessor :password

    def to_param
      login
    end

    # Does the user have the possibility to authenticate with a one time password?
    def has_otp_device?
      !yubico_identity.nil?
    end

    # Is the Yubico OTP valid and belongs to this account?
    def yubikey_authenticated?(otp)
      if yubico_identity? && Account.verify_yubico_otp(otp)
        (Account.extract_yubico_identity_from_otp(otp) == yubico_identity)
      else
        false
      end
    end

    def authenticated_with_yubikey?
      @authenticated_with_yubikey || false
    end

    def associate_with_yubikey(otp)
      if Account.verify_yubico_otp(otp)
        self.yubico_identity = Account.extract_yubico_identity_from_otp(otp)
        save(:validate => false)
      else
        false
      end
    end

    def disable!
      update_attribute(:enabled, false)
    end

    private

    # Returns the first twelve chars from the Yubico OTP,
    # which are used to identify a Yubikey
    def self.extract_yubico_identity_from_otp(yubico_otp)
      yubico_otp[0..11]
    end

    # Recieves a login token which consists of the users password and
    # a Yubico one time password (the otp is always 44 characters long)
    def self.split_password_and_yubico_otp(token)
      token.reverse!
      yubico_otp = token.slice!(0..43).reverse
      password = token.reverse
      [password, yubico_otp]
    end

    # Utilizes the Yubico library to verify an one time password
    def self.verify_yubico_otp(otp)
      yubico = Yubico.new(Masq::Engine.config.masq['yubico']['id'], Masq::Engine.config.masq['yubico']['api_key'])
      yubico.verify(otp) == Yubico::E_OK
    end

    def deliver_forgot_password
      AccountMailer.forgot_password(self).deliver if recently_forgot_password?
    end

  end
end
