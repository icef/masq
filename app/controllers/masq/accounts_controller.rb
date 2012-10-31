module Masq
  class AccountsController < ApplicationController
    # before_filter :check_disabled_registration, :only => [:new, :create] # TODO: move?
    before_filter :authenticate_account!, :except => [:show, :new, :create, :activate, :resend_activation_email]
    before_filter :detect_xrds, :only => :show

    def show
      @account = Account.by_devise_account(:login => params[:account])
      raise ActiveRecord::RecordNotFound if @account.nil?

      respond_to do |format|
        format.html do
          response.headers['X-XRDS-Location'] = identity_url(:account => @account, :format => :xrds, :protocol => scheme)
        end
        format.xrds
      end
    end

    def update
      attrs = params[:account]
      attrs.delete(:email) if email_as_login?
      attrs.delete(:login)

      if current_account.masq_account.update_attributes(attrs)
        redirect_to edit_account_path(:account => current_account.masq_account), :notice => t(:profile_updated)
      else
        render :action => 'edit'
      end
    end

    protected

    def check_disabled_registration
      render_404 if Masq::Engine.config.masq['disable_registration']
    end

    def detect_xrds
      if params[:account] =~ /\A(.+)\.xrds\z/
        request.format = :xrds
        params[:account] = $1
      end
    end
  end
end
