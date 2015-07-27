class StaticPagesController < ApplicationController
  def Home
    if logged_in?
      redirect_to current_user
    end
  end

  def About
  end

  def Faq
  end

  def Partners
  end

  def Pricing
  end

  def Contact
  end
end
