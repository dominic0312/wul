module Usercenter
  class ConsoleController< ApplicationController
    layout "usercenter"

    before_filter :authenticate_user!, :set_cache_buster

    def index

    end

    def overview
      @deposit = current_user.user_info.account
    end

    def history
      @transactions = Transaction.all
    end

    def charge

    end

    def assets_analyzer

    end

    def redemption

    end

    def agreements

    end

    def autoinvest

    end

    def invest_history
      @invests = current_user.user_info.invests
    end

    def charge_mock
      logger.info(params[:charge_value])
      if current_user
        current_user.user_info.account.balance += params[:charge_value].to_i
        current_user.user_info.save!
      end
      render usercenter_console_charge_bank_path
    end

    def bankcard
      @bankcards = current_user.bankcards
    end

    def coupon
      @coupons = current_user.coupons
    end


    def create_order
      @product = FixedDeposit.find(params[:format])
    end

    def join
      @product = FixedDeposit.find(params[:format])
      invest = Invest.new
      invest.loan_number = @product.deposit_number
      invest.amount = params[:product_value].to_i

      invests = current_user.user_info.invests
      current_amount = 0
      invests.each{|inv| current_amount += inv.amount if inv.loan_number == @product.deposit_number}
      if current_amount + invest.amount > 100000
          flash[:notice] = "已经超过本产品购买额度"
          redirect_to fixed_deposit_path(params[:format]) and return
      end


      if current_user.user_info.account.balance >= invest.amount and @product.free_invest_amount >= invest.amount
         @product.free_invest_amount -= invest.amount
         current_user.user_info.account.balance -= invest.amount
         current_user.save!
         @product.save!
         invest.create_transaction(current_user.user_info.account)
         current_user.user_info.invests << invest
         invest.save!
      else
        flash[:notice] = "账户余额或产品可投资余额不足"
      end
      redirect_to fixed_deposit_path(params[:format]) and return
    end

    def save_order
      if params[:product_value].to_i > (current_user.account.balance - current_user.account.frozen_balance)
          render "shared/balance_error" and return
      end
      order = Order.new
      order.product_type = params[:product_type]
      order.product_id = params[:product_id]
      order.product_value = params[:product_value].to_i
      current_user.orders << order
      current_user.account.frozen_balance += order.product_value
      current_user.save!
      order.create_transaction(current_user.account)
      order.save!
      redirect_to usercenter_console_history_path
    end

    def set_cache_buster
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

  end
end