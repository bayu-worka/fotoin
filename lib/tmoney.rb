class Tmoney
  def initialize
    # @client_id = ENV["XSIGHT_CLIENT_ID"]
    # @client_secret = ENV["XSIGHT_CLIENT_SECRET"]
    @access_token = ENV["TMONEY_ACCESS_TOKEN"]
  end

  # def get_access_token
  #   params = URI.encode_www_form({grant_type: "client_credentials"})
  #   auth = {username: @client_id, password: @client_secret}
  #   response = HTTParty.post("https://api.mainapi.net/token", 
  #             :body => params,
  #             :basic_auth => auth,
  #             :headers => { 'Content-Type' => 'application/x-www-form-urlencoded'}
  #             )
  #   if response.parsed_response["access_token"]
  #     @access_token = response.parsed_response["access_token"]
  #   else
  #     @error = response.parsed_response["error_description"]
  #   end
  # end

  def check_email(email)
    if @access_token
      params = URI.encode_www_form({userName: email, terminal: ENV["TMONEY_TERMINAL"], apiKey: ENV["TMONEY_API_KEY"]})
      result = HTTParty.post("#{ENV['TMONEY_ENDPOINT']}/email-check", 
                            :body => params,
                            :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Authorization' => "Bearer #{@access_token}" } )
      if result.parsed_response["resultCode"]
        @result_code = result.parsed_response["resultCode"] # 187 user already registered, 188 user available
        @message = result.parsed_response["resultDesc"]
      else
        @error = result.parsed_response
      end
    else
      @error
    end
  end

  def sign_up(acc_type=1, user_name, password, full_name, phone)
    if @access_token
      params = URI.encode_www_form({accType: acc_type, userName: user_name, password: password, fullName: full_name, phoneNo: phone, terminal: ENV["TMONEY_TERMINAL"], apiKey: ENV["TMONEY_API_KEY"]})
      result = HTTParty.post("#{ENV['TMONEY_ENDPOINT']}/sign-up", 
                            :body => params,
                            :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Authorization' => "Bearer #{@access_token}" } )
      if result.parsed_response["status"]
        @register_status = true
        @result_code = result.parsed_response["resultCode"]
        @message = result.parsed_response["resultDesc"]
        @activation_code = result.parsed_response["activationCode"]
      else
        @error = result.parsed_response
      end
    else
      @error
    end
  end

  def email_verification
    if @access_token
      params = URI.encode_www_form({code: @activation_code, terminal: ENV["TMONEY_TERMINAL"], apiKey: ENV["TMONEY_API_KEY"]})
      result = HTTParty.post("#{ENV['TMONEY_ENDPOINT']}/email-verification", 
                            :body => params,
                            :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Authorization' => "Bearer #{@access_token}" } )
      if result.parsed_response["resultCode"]
        @result_code = result.parsed_response["resultCode"]
        @message = result.parsed_response["resultDesc"]
      else
        @error = result.parsed_response
      end
    else
      @error
    end
  end

  def sign_in(email, password)
    if @access_token
      params = URI.encode_www_form({userName: email, password: password, datetime: @now, terminal: ENV["TMONEY_TERMINAL"], apiKey: ENV["TMONEY_API_KEY"], signature: @signature})
      result = HTTParty.post("#{ENV['TMONEY_ENDPOINT']}/sign-in", 
                            :body => params,
                            :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Authorization' => "Bearer #{@access_token}" } )

      if result.parsed_response["login"]
        @sessionId = result.parsed_response["user"]["sessionId"]
        @id_tmoney = result.parsed_response["user"]["idTmoney"]
        @id_fusion = result.parsed_response["user"]["idFusion"]
        @token = result.parsed_response["user"]["token"]
      else
        @error = result.parsed_response["resultDesc"]
      end
    else
      @error
    end
  end

  def generate_signature(email)
    @now = Time.now.strftime("%Y-%m-%d %H:%M")
    data = "#{email}#{@now}#{ENV['TMONEY_TERMINAL']}#{ENV['TMONEY_API_KEY']}"
    @signature = OpenSSL::HMAC.hexdigest("SHA256", ENV["TMONEY_API_KEY"], data)
  end
  
  def transfer_p2p()
    
  end
end