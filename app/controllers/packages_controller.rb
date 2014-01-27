class PackagesController < ApplicationController
  def show
    @package = Package.find(params[:id])
  end

  def purchase
    @package = Package.find(params[:id])

    customer = Stripe::Customer.create(
      :email => current_user.email,
      :card  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @package.amount,
      :description => @package.description,
      :currency    => 'gbp'
    )

    current_user.package = @package
    current_user.save!

    redirect_to @package, notice: "Thank you for ordering!"

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to @package
  end
end
