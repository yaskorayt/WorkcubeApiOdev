<cfcomponent displayname="Kripto" output="false">
    <cffunction name="updateExchangeRates" access="public" returntype="void" output="false">
        <cftry>
            <!--- Binance API'den verileri çekme --->
            <cfhttp url="https://api.binance.com/api/v3/ticker/price"
                    method="get"
                    result="apiResponse">
                <cfhttpparam type="header" name="X-MBX-APIKEY" value="aRy8rH6xx27IrQbgRqSByPIdSJHarGARh7jYMwxACOx6ZpRnLcboNLB8BZMKFzNK">
            </cfhttp>

            <cfset var data = deserializeJSON(apiResponse.fileContent)>

            <!--- Veritabanına bağlanma ve işlemleri gerçekleştirme --->
            <cfquery datasource="DSN" name="truncateTable">
                TRUNCATE TABLE workcube_dv.EXCHANGE_RATE
            </cfquery>
            
            <!--- Veri geldi mi kontrolü --->
            <cfif structKeyExists(apiResponse, "fileContent")>
                <!--- API'den veri geldi --->
                <cfloop array="#data#" index="item">
                    <cfquery datasource="DSN" name="insertData">
                        INSERT INTO workcube_dv.EXCHANGE_RATE (SYMBOL, PRICE)
                        VALUES (
                            <cfqueryparam value="#item.symbol#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#item.price#" cfsqltype="cf_sql_numeric">
                        )
                        ON DUPLICATE KEY UPDATE PRICE = <cfqueryparam value="#item.price#" cfsqltype="cf_sql_numeric">
                    </cfquery>
                </cfloop>
            <cfelse>
                <!--- API'den veri gelmedi, hata durumu --->
                <cflog file="application" text="Error: No data received from Binance API">
                <cfthrow message="No data received from Binance API">
            </cfif>
            
            <cfcatch type="any">
                <cfset var errorMessage = cfcatch.message>
                <!--- Hata durumunda yapılacak işlemler --->
                <cflog file="application" text="Error updating exchange rates: #errorMessage#">
            </cfcatch>
        </cftry>
    </cffunction>
</cfcomponent>
