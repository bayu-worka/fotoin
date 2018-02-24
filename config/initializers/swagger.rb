class Swagger::Docs::Config
  def self.transform_path(path, api_version)
    # Make a distinction between the APIs and API documentation paths.
    "apidocs/#{path}"
  end
end

Swagger::Docs::Config.base_api_controller = Api::V1::ApiController

Swagger::Docs::Config.register_apis({
  "1.0" => {
    # the extension used for the API
    :api_extension_type => :json,
    # the output location where your .json files are written to
    # public/apidocs
    :api_file_path => "public/apidocs",
    # the URL base path to your API
    :base_path => ENV["WEBAPP_DOMAIN"],
    # if you want to delete all .json files at each generation
    :clean_directory => true,
    # Ability to setup base controller for each api version. Api::V1::SomeController for example.
    :parent_controller => Api::V1::ApiController,
    # add custom attributes to api-docs
    :attributes => {
      :info => {
        "title" => "Fotoin",
        "description" => "Fotoin.",
        # "termsOfServiceUrl" => "http://helloreverb.com/terms/",
        "contact" => "bayu@worka.id"
        # "license" => "Apache 2.0",
        # "licenseUrl" => "http://www.apache.org/licenses/LICENSE-2.0.html"
      }
    }
  }
})