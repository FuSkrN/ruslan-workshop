using System;
using System.Threading;

namespace bruh_soundeffect2mp3
{
    class Program
    {
        static StonksUtils _stonks = new StonksUtils();

        static void Main(string[] args)
        {
            bool hasStocks = false;
            while (true) 
            {
                int[] marketData = GetMarketData();
                int numElements = marketData.Length;

                // ------------------------------------------------------ // 
                //          THIS IS WHERE YOU WRITE YOUR CODE!            // 
                //                      GOOD LUCK!                        //
                // ------------------------------------------------------ //

                int firstPrice = marketData[0];  // Get the first price 
                int lastPrice = marketData[numElements-1];  // Get the last price
                
                int thirtyLast = marketData[numElements-30];
                int seg3 = 0;

                for(int i = thirtyLast; i < lastPrice; i++){
                    seg3 += marketData[i];
                } 
                float averageSeg3 = seg3 / 30f;


                if (hasStocks){
                    if (firstPrice < lastPrice){
                       if(seg3 <= 0) {
                           Sell();
                           hasStocks = false;
                       } 
                       else if (seg3 > 0) {
                           //Do nothing
                       }
                    } 
                    else if (firstPrice == lastPrice){
                         if (averageSeg3 > lastPrice ){ //dvs. seg3 falder
                            Sell();
                            hasStocks = false;
                        }
                        else if (averageSeg3 <= lastPrice){ //dvs. seg3 stiger
                            //Do nothing
                        }
                    }
                    else if (firstPrice > lastPrice){
                        Sell();
                        hasStocks = false;
                    }
                } 
                else {
                    if (firstPrice < lastPrice){
                        Buy();
                        hasStocks = true;
                    }
                    else if (firstPrice == lastPrice){
                        if (averageSeg3 > lastPrice){ //dvs. seg3 falder
                            //Do nothing
                        }
                        else if (averageSeg3 <= lastPrice){ //dvs. seg3 stiger
                            Buy();
                            hasStocks = true;
                        }
                    }
                    else if (firstPrice > lastPrice){
                        if (averageSeg3 > lastPrice ){ //dvs. seg3 falder
                            //Do nothing
                        }
                        else if (averageSeg3 <= lastPrice){ //dvs. seg3 stiger
                            Buy();
                            hasStocks = true;
                        }
                    }
                }

                /*
                if (firstPrice > lastPrice)
                {
                    // The price has risen from the first to the last data point, 
                    // so the trend is rising - buy!
                    Buy();
                }
                else if (firstPrice < lastPrice)
                {
                    // The price has fallen from the first to the last data point, 
                    // so the trend is falling - sell!
                    Sell();
                }
                */


                // ------------------------------------------------------ //
                //          THE FOLLOWING IS EXAMPLE CODE - IT            // 
                //          CHECKS THE FIRST AND LAST PRICES IN           // 
                //          THE MARKET DATA AND:                          // 
                //                                                        // 
                //          FIRST < LAST      ---->      BUY              // 
                //          FIRST > LAST      ---->      SELL             // 
                //          FIRST = LAST      ---->      STAY             //
                //                                                        // 
                //          FEEL FREE TO REPLACE WITH YOUR OWN!           //
                //                                                        // 
                // ------------------------------------------------------ //

            }
        }

































        static int[] GetMarketData()
        {
            // Wait for some time (don't kill the server)
            Thread.Sleep(Environment.GetEnvironmentVariable("RUSLAN_API_PORT") == null ? 5000 : 10000);
            GroupInfo info = _stonks.GetInfo();

            // Determine the timespan you want info within (this is the last 5 minutes)
            DateTime to = Environment.GetEnvironmentVariable("RUSLAN_API_PORT") == null ? DateTime.Now - TimeSpan.FromDays(2) : DateTime.Now;
            DateTime from = to - TimeSpan.FromMinutes(5);


            // Get the market data
            return _stonks.GetMarketData(from, to);
        }

        static void Buy() 
        {
            try 
            {
                _stonks.Buy();
                Console.WriteLine("Bought Ligma Inc.!");
            } 
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        static void Sell()
        {
            try
            {
                _stonks.Sell();
                Console.WriteLine("Sold Ligma Inc.!");
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);                
            }
        }
    }
}
