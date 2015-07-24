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
        hello_test += "\n\n " + clicks_data_subset.to_s + "\n\n"

        banner_revenue = Array.new
        count = 0
        last_banner_id = -1
        for click in clicks_data_subset
            for conversion in conversions_data
                if (click[:click_id].to_i == conversion[:click_id].to_i)
                    hello_test += "click generated " + conversion[:revenue].to_s + " on banner " + click[:banner_id].to_s + "\n"

                    if last_banner_id == click[:banner_id]
                        banner_revenue[count-1][:revenue]  += conversion[:revenue]
                    else
                        banner_revenue[count] = {:banner_id => click[:banner_id], :revenue => conversion[:revenue]}
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
   
        #Get the top10 banners according to revenue 
        hello_test += "\n number of banners with revenue: " + banner_revenue.size.to_s + "\n" 
        
        if banner_revenue.size.to_i > 0
            count = 0
            while count < 10 && count < banner_revenue.size.to_i
                hello_test += "\n" + count.to_s + " banner=" + banner_revenue[count][:banner_id].to_s + " rev=" + banner_revenue[count][:revenue].to_s
                count += 1
            end
        end    

        #display random banners while making sure that a banner is not showed twice the same session until all other are shown from that session
        count = 0
        session[:ads_served] = [] #Create a session array for ads served
        random_pos = rand(0..([10, banner_revenue.size.to_i].min.to_i-1)) #initial random banner
        while count < 20
            
            #check if banner already displayed this session and don't display it again until all ads have been displayed
            while (random_pos == -1 || (session[:ads_served].include? banner_revenue[random_pos.to_i][:banner_id].to_s)) do 
                if session[:ads_served].size.to_i == ([10, banner_revenue.size.to_i].min) 
                    session[:ads_served].clear
                end

                random_pos = rand(0..([10, banner_revenue.size.to_i].min.to_i-1))   


                if session[:ads_served].include? banner_revenue[random_pos.to_i][:banner_id].to_s
                end
            end

            banner_to_display = banner_revenue[random_pos][:banner_id]
            session[:ads_served][count.to_i%[10, banner_revenue.size.to_i].min.to_i] = banner_to_display.to_s
            count += 1


            hello_test += "\nbanner to display: " + banner_to_display.to_s + "  pos[" + random_pos.to_s + "]"
        end

        return hello_test
#        return banner_to_display.to_s
    end
end
