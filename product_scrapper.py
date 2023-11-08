# Import libries 

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import json

# Brand name
brand = "Panasonic"

#Maximun number of pages that we are scrapping 
max_pages = 10

#Create a empty json file

with open('{}.json'.format(brand),'w') as f:
     json.dump([],f)
     

def json_writer(new_data , file_name = '{}.json'.format(brand)):
     with open(file_name , 'r+') as file:
          
          # Load existing data into a dict
          dic_data = json.load(file)


          # Append new data
          dic_data.append(new_data)

          file.seek(0)

          # Convert back to json
          json.dump(dic_data, file, indent=4)


# create the driver 

driver = webdriver.Chrome()

driver.get("https://www.amazon.com/s?k=laptop&i=electronics&crid=1B8U8IEJSUS84&sprefix=%2Celectronics%2C547&ref=nb_sb_ss_recent_1_0_recent")

#click on See more icon

icon = driver.find_element(By.CLASS_NAME,'a-icon-extender-expand')

icon.click()


# Find the brand name that we provided 
search_button = driver.find_element(By.XPATH,'//*[@id="p_89/{}"]/span/a/div/label/i'.format(brand))
    
search_button.click()

page_num = 1

while page_num<= max_pages:

    try:
        
        WebDriverWait(driver,10).until(EC.presence_of_element_located((By.XPATH,'//div[@data-component-type="s-search-result"]')))


        item =driver.find_element(By.CSS_SELECTOR,"div.s-desktop-width-max.s-desktop-content.s-wide-grid-style-t1.s-opposite-dir.s-wide-grid-style.sg-row ")
         
        
#Get all items in the first page

        elements = item.find_elements(By.XPATH,'//div[@data-component-type="s-search-result"]')


        for elm in elements:

                        title = "N/A"
                        price = "N/A"
                        review_count = "N/A"
                        rating ="N/A"
                        Intialprice = "N/A"
                        
        #Get titles

                        try:
                            title = elm.find_element(By.TAG_NAME,'h2').text
                        
                        except:
                            pass


        #Get selling price
                        try:

                            price = elm.find_element(By.CSS_SELECTOR,'.a-price').text.replace('\n','.')

                        except:
                            pass
                        
        #Get the Intial price

                        try:
                            Intialprice = elm.find_element(By.CSS_SELECTOR,'.a-price.a-text-price').text
                            
                        
                        except:
                            pass
                        
                        
            
        #Get review count 
                        try:

                            review_count = elm.find_element(By.CSS_SELECTOR,'.a-size-base').text
                        except:
                            pass

        #Get ratings 
                        try:
                            
                            rating_elm = elm.find_elements(By.XPATH,'//div[@class="a-row a-size-small"]/span')
                            rating = rating_elm[0].get_attribute('aria-label')
                            
                            
                        except:
                            pass
                            

                        #print("Brand:"+brand)
                        #print("title:"+title)
                        #print("price:"+price)
                        #print("intialprice:"+Intialprice)
                        #print("review_count:"+review_count)
                        #print("rating:"+rating+'\n')

        #Write data into json file
                        json_writer({
                            "Brand":brand,
                            "Title":title,
                            "Intialprice":Intialprice,
                            "SellingPrice":price,
                            "Reviews":review_count,
                            "Rating":rating
                        })

                        
                
     # Next button
        try:
            next_button = WebDriverWait(driver,10).until(EC.presence_of_element_located((By.CLASS_NAME,'s-pagination-next')))
            next_button.click()
        
        except Exception as e:
            print("Error while navigating to the next page:", str(e))
            break  # Exit the loop if there's an issue
        
        page_num += 1
    
    except Exception as e:
         print(e ,"error")
        
driver.quit()
     

    




     
             
         
