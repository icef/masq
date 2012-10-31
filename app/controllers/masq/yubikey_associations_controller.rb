module Masq
  class YubikeyAssociationsController < ApplicationController
    before_filter :authenticate_account!

    def create
      if current_account.masq_account.associate_with_yubikey(params[:yubico_otp])
        flash[:notice] = t(:account_associated_with_yubico_identity)
      else
        flash[:alert] = t(:sorry_yubico_one_time_password_incorrect)
      end
      respond_to do |format|
        format.html { redirect_to edit_account_path }
      end
    end

    def destroy
      current_account.masq_account.yubico_identity = nil
      current_account.masq_account.save

      respond_to do |format|
        format.html { redirect_to edit_account_path, :notice => t(:account_disassociated_from_yubico_identity) }
      end
    end
  end
end
