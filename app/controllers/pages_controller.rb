class PagesController < ApplicationController

    def campaigns
        if params[:campaign_id].to_i >= 5
        end
    end

    def get_banner(name)
        hello_test = "hello, " + name
        hello_test += " welcome\n"  
    
      
      csv_clicks= CSV.read("app/assets/csv/clicks_1.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all} )

        hashed_data = csv_clicks.map { |d| d.to_hash }
        hello_test += hashed_data[0][:click_id].to_s + "\n"
        hello_test += hashed_data[1][:click_id].to_s + "\n"
        hello_test += hashed_data[2][:click_id].to_s + "\n"

        hashed_data.reverse!
        hello_test += hashed_data[0][:click_id].to_s + "\n"
        hello_test += hashed_data[1][:click_id].to_s + "\n"
        hello_test += hashed_data[2][:click_id].to_s
#            csv_convs = File.read("app/assets/csv/conversions_1.csv")
 #           csv_imps = File.read("app/assets/csv/impressions_1.csv")

      #      csv_clicks = CSV.parse(csv_clicks, :headers => true) do |row|
     #           hello_test += row.to_s + "\n"
    #        end

#            csv_convs =  CSV.parse(csv_convs, :headers => true)
 #           csv_imps = CSV.parse(csv_imps, :headers => true)
        return hello_test
    end
end
