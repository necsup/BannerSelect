class PagesController < ApplicationController

    def campaigns
        if params[:campaign_id].to_i >= 5
        end
    end

    def say_hello(name)
        hello_test = "hello, " + name
        hello_test += " welcome"
    
            csv_clicks= File.read("app/assets/csv/clicks_1.csv")
            csv_convs = File.read("app/assets/csv/conversions_1.csv")
            csv_imps = File.read("app/assets/csv/impressions_1.csv")

            csv_clicks = CSV.parse(csv_clicks, :headers => true) do |row|
                hello_test += row.to_s
            end

            csv_convs =  CSV.parse(csv_convs, :headers => true)
            csv_imps = CSV.parse(csv_imps, :headers => true)
#       hello_test += csv_clicks
        return hello_test
    end
end
