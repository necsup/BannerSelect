class PagesController < ApplicationController

    def campaigns
        if params[:campaign_id].to_i >= 5
        end
    end

    def get_banner(campaign_id)
    
      
      csv_clicks= CSV.read("app/assets/csv/clicks_1.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all} )
      csv_conversions= CSV.read("app/assets/csv/conversions_1.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all} )
        hello_test = campaign_id.to_s +  "\n"

        clicks_data = csv_clicks.map { |d| d.to_hash }
        conversions_data = csv_conversions.map { |d| d.to_hash}
        hello_test += clicks_data[0][:click_id].to_s + "\n"
        hello_test += clicks_data[1][:click_id].to_s + "\n"
        hello_test += clicks_data[2][:click_id].to_s + "\n"

        clicks_data.reverse!
        hello_test += clicks_data[0][:click_id].to_s + "\n"
        hello_test += clicks_data[1][:click_id].to_s + "\n"
        hello_test += clicks_data[2][:click_id].to_s + "\n"

        clicks_data.sort_by! { |v| v[:banner_id]}
        
        #get a subet for only current campaign id
        count = 0;
        clicks_data_subset = Array.new
        for click in clicks_data
            if click[:campaign_id].to_i == campaign_id.to_i
                clicks_data_subset[count] = click.to_h
                count += 1
            end
        end
        clicks_data_subset.sort_by! {|v| v[:banner_id]}
        #hello_test += clicks_data_subset.to_s 

        banner_revenue = Array.new
        count = 0
        for click in clicks_data_subset
            hello_test += click[:click_id].to_s + " "
            for conversion in conversions_data
                if (click[:click_id].to_i == conversion[:click_id].to_i)
                    hello_test += "click generated " + conversion[:revenue].to_s + " on banner " + click[:banner_id].to_s
                    banner_revenue[count] = {:banner_id => click[:banner_id], :revenue => conversion[:revenue]}
                    count += 1
                end
            end  
            hello_test += "\n"
        end

        hello_test += banner_revenue.to_s

           

        return hello_test
    end
end
