class PagesController < ApplicationController

    def campaigns
        if params[:campaign_id].to_i >= 5
            csv_clicks= File.read("app/assets/csv/clicks_1.csv")
            csv_convs = File.read("app/assets/csv/conversions_1.csv")
            csv_imps = File.read("app/assets/csv/impressions_1.csv")

            csv_clicks= CSV.parse(csv_clicks, :headers => true)
        end
    end
end
