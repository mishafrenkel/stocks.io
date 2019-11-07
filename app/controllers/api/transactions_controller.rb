class Api::TransactionsController < ApplicationController
  def create
    @transaction = Transaction.new(transaction_params)
    @user = User.find(@transaction.user_id);
    dollar_amount = @transaction.stock_price * @transaction.num_shares
    if @transaction.transaction_type == "purchase"
      if @user.buying_power < dollar_amount
        render json: ["Not enough buying power"], status: :unprocessable_entity
        return
      else
        @user.buying_power -= dollar_amount
      end
    elsif @transaction.transaction_type == "sale"
      if @user.num_shares(@transaction.symbol) < @transaction.num_shares
        render json: ["Not enough shares"], status: :unprocessable_entity
        return
      else
        @user.buying_power += dollar_amount
      end
    end
    @user.save!
    if @transaction.save
      render "api/transactions/show"
    else
      render json: @transaction.errors.full_messages, status: :unprocessable_entity
    end
  end



  private

  def transaction_params
    params.require(:transaction).permit(:user_id, :symbol, :transaction_type, :stock_price, :num_shares)
  end
end
