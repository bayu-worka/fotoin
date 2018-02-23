class MomentsController < ApplicationController
  before_action :set_moment, only: [:show, :donation, :make_donation]
  before_action :set_moment_owned, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :make_donation, :donation]
  before_action :validate_donation_type_moment, only: [:donation, :make_donation]

  # GET /moments
  # GET /moments.json
  def index
    @moments = Moment.page(params[:page])
  end

  # GET /moments/1
  # GET /moments/1.json
  def show
  end

  # GET /moments/new
  def new
    @moment = current_user.moments.new
  end

  # GET /moments/1/edit
  def edit
  end

  # POST /moments
  # POST /moments.json
  def create
    @moment = current_user.moments.new(moment_params)

    respond_to do |format|
      if @moment.save
        format.html { redirect_to @moment, notice: 'Moment was successfully created.' }
        format.json { render :show, status: :created, location: @moment }
      else
        format.html { render :new }
        format.json { render json: @moment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /moments/1
  # PATCH/PUT /moments/1.json
  def update
    respond_to do |format|
      if @moment.update(moment_params)
        format.html { redirect_to @moment, notice: 'Moment was successfully updated.' }
        format.json { render :show, status: :ok, location: @moment }
      else
        format.html { render :edit }
        format.json { render json: @moment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /moments/1
  # DELETE /moments/1.json
  def destroy
    @moment.destroy
    respond_to do |format|
      format.html { redirect_to moments_url, notice: 'Moment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def donation
    @donation = @moment.donations.new
  end

  def make_donation
    @donation = @moment.donations.new(donation_params.merge(user: current_user))
    if @donation.save
      redirect_to moment_path(@moment), notice: "Anda telah berhasil melakukan donasi"
    else
      render :donation
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_moment
      @moment = Moment.find(params[:id])
    end

    def set_moment_owned
      @moment = current_user.moments.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def moment_params
      params.require(:moment).permit(:title, :description, :moment_type, photos_attributes: [:id, :description, :title, :image, :_destroy])
    end

    def donation_params
      params.require(:donation).permit(:amount, :tmoney_email, :tmoney_password)
    end

    def validate_donation_type_moment
      redirect_to moment_path(@moment), notice: "Hanya Moment bertipe Donasi yang dapat menerima donasi" unless @moment.moment_type.eql?("donation")
    end
end
