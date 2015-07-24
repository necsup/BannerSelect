class PagesController < ApplicationController

    def campaigns
        if params[:campaign_id].to_i >= 5
        end
    end

    def get_banner(campaign_id)
    
      
      csv_clicks= CSV.read("app/assets/csv/clicks_1.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all} )
        hello_test = campaign_id.to_s +  "\n"

        hashed_data = csv_clicks.map { |d| d.to_hash }
        hello_test += hashed_data[0][:click_id].to_s + "\n"
        hello_test += hashed_data[1][:click_id].to_s + "\n"
        hello_test += hashed_data[2][:click_id].to_s + "\n"

        hashed_data.reverse!
        hello_test += hashed_data[0][:click_id].to_s + "\n"
        hello_test += hashed_data[1][:click_id].to_s + "\n"
        hello_test += hashed_data[2][:click_id].to_s + "\n"

        hashed_data.sort_by! { |v| v[:banner_id]}
        count = 0;
        hashed_data2 = Array.new
        for campaign in hashed_data
            if campaign[:campaign_id].to_i == campaign_id.to_i
        #        hello_test += campaign[:campaign_id].to_s + " " + campaign[:click_id].to_s + " "+ campaign[:banner_id].to_s + "\n"
                hashed_data2[count] = campaign.to_h
                count += 1
            end
        end
        hello_test += "---" + hashed_data2[5][:click_id].to_s + "\n"        
        hashed_data2.sort_by! {|v| v[:banner_id]}
#        hashed_data2.reverse!
        hello_test += hashed_data2.to_s 

        return hello_test
    end
end
