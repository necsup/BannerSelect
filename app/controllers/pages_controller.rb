class PagesController < ApplicationController

    def campaigns
        if params[:campaign_id].to_i >= 5
        end
    end

    def get_banner(campaign_id)
    
      hello_test = ""  
      csv_clicks= CSV.read("app/assets/csv/clicks_1.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all} )
      csv_conversions= CSV.read("app/assets/csv/conversions_1.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all} )

        clicks_data = csv_clicks.map { |d| d.to_hash }
        conversions_data = csv_conversions.map { |d| d.to_hash}

        
        #get a subet for only current campaign id
        count = 0;
        clicks_data_subset = Array.new
        for click in clicks_data
            if click[:campaign_id].to_i == campaign_id.to_i
                clicks_data_subset[count] = click.to_h
                count += 1
            end
        end

        #banners with conversions, note that the clicks have to be sorted according to banner_id for this block
        #since it sums up the revenues for each banner and checks if last_banner_id == banner_id

        clicks_data_subset.sort_by! {|v| v[:banner_id]}

        banner_revenue = Array.new
        count = 0
        last_banner_id = -1
        for click in clicks_data_subset
            for conversion in conversions_data
                if (click[:click_id].to_i == conversion[:click_id].to_i)
                    hello_test += "click generated " + conversion[:revenue].to_s + " on banner " + click[:banner_id].to_s + "\n"
   
                    banner_revenue[count] = {:banner_id => click[:banner_id], :revenue => conversion[:revenue]}
                    if last_banner_id == click[:banner_id]
                        banner_revenue[count-1][:revenue]  += conversion[:revenue]
                    else
                        last_banner_id = click[:banner_id]
                        count += 1
                    end
                end
            end  
        end

        #sort by revenue
        banner_revenue.sort_by! {|v| v[:revenue]}
        banner_revenue.reverse!
        hello_test += banner_revenue.to_s
   
#        banner_to_display = banner_revenue[0][:banner_id]
#        hello_test += "\n" + banner_to_display.to_s 
        
        hello_test += "\n number of banners with revenue: " + banner_revenue.size.to_s + "\n" 
        
        if banner_revenue.size.to_i > 5
            count = 0
            while count < 10 && count <= banner_revenue.size.to_i
                hello_test += "\n" + count.to_s + " banner=" + banner_revenue[count][:banner_id].to_s + " rev=" + banner_revenue[count][:revenue].to_s
                count += 1
            end
        end    

        return hello_test
        return banner_to_display.to_s
    end
end
