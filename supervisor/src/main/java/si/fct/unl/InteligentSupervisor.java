/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package si.fct.unl;

/**
 *
 * @author bruno and henrique
 */

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.rapidoid.http.HTTP;
import org.rapidoid.http.Req;
import org.rapidoid.http.ReqHandler;
import org.rapidoid.setup.My;
import org.rapidoid.setup.On;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONString;
import java.lang.StringBuilder;

/*
This class is based on a Java thread, which runs permanently and will take care of planning,  monitoring, failures detection, diagnosis and recover.
*/

public class InteligentSupervisor extends Thread{
    
    private Warehouse warehouse;
    private WebServer webserver;

    private boolean interrupted = false;

    public InteligentSupervisor(Warehouse warehouse) {
        this.warehouse = warehouse;
        this.warehouse.initializeHardwarePorts();
    }

    public void setInterrupted(boolean value) {
        this.interrupted = value;
    }
    
    public void startWebServer() {
        On.port(8082);        
        On.get("/").html((req, resp) -> "Inteligent supervision server");
        
        On.get("/x-move-right").serve(req -> {
            warehouse.moveXRight();
            req.response().plain("OK");
            return req;
        });

        On.get("/x-move-left").serve(req -> {
            warehouse.moveXLeft();
            req.response().plain("OK");
            return req;
        });

        On.get("/x-stop").serve(req -> {
            warehouse.stopX();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/y-move-inside").serve(req -> {
            warehouse.moveYInside();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/y-move-outside").serve(req -> {
            warehouse.moveYOutside();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/y-stop").serve(req -> {
            warehouse.stopY();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/z-move-up").serve(req -> {
            warehouse.moveZUp();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/z-move-down").serve(req -> {
            warehouse.moveZDown();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/z-stop").serve(req -> {
            warehouse.stopZ();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/left-station-inside").serve(req -> 
        {
            warehouse.moveLeftStationInside();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/left-station-outside").serve(req -> 
        {
            warehouse.moveLeftStationOutside();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/left-station-stop").serve(req -> 
        {
            warehouse.stopLeftLtation();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/right-station-inside").serve(req -> 
        {
            warehouse.moveRightStationInside();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/right-station-outside").serve(req -> 
        {
            warehouse.moveRightStationOutside();
            req.response().plain("OK");
            return req;
        });
        
        On.get("/right-station-stop").serve(req -> 
        {
            warehouse.stopRightStation();
            req.response().plain("OK");
            return req; 
        });
        
          
        On.get("/execute_remote_query").serve(new ReqHandler() {
            @Override
            public Object execute(Req req) throws Exception {
                String the_query = URLEncoder.encode(req.param("query"), StandardCharsets.UTF_8);
                //String result = HTTP.get("http://localhost:8083/execute_remote_query?query="+the_query).execute().result();
                String result = InteligentSupervisor.this.executePrologQuery(the_query);
                req.response().plain(result);
                return req;
            }
        });
        
        My.errorHandler((req,resp,error) -> 
        {
            return resp.code(200).result("Error:" + error.getMessage());
        });
        
        On.get("/read_sensor_values").serve( req -> {
            JSONObject jsonObj = obtainSensorInformation();
            req.response().plain(jsonObj.toString());
            return req;
        });
        
        
    }
    
    synchronized String executePrologQuery(String query)
    {
        String result = HTTP.get("http://localhost:8083/"+ query).execute().result();
        try
        {
            Thread.sleep(2);
            
        }
        catch (InterruptedException ex)
        {
            Logger.getLogger(InteligentSupervisor.class.getName()).log(Level.SEVERE, null, ex);
        }
        return result;
    }
    
    
    public void updateKnowledgeBase()
    {
        int position, state;
        StringBuilder queryStates = new StringBuilder("true");
        
        position = warehouse.getXPosition();
        
        if(position != -1 ){
            queryStates.append(String.format(",assert_once(x_is_at(%d))",position));
        }
        else{
            queryStates.append(",retractall(x_is_at(_))");
        }
        
        
        position = warehouse.getYPosition();
        
        if(position != -1 ){
            queryStates.append(String.format(",assert_once(y_is_at(%d))",position));
        }
        else{
            queryStates.append(",retractall(y_is_at(_))");
        } 

                
        position = warehouse.getZPosition();
        
        if(position != -1 ){
            queryStates.append(String.format(",assert_once(z_is_at(%d))",position));
        }
        else{
            queryStates.append(",retractall(z_is_at(_))");
        }
        
        queryStates.append(String.format(",assert_once(x_moving(%d))",warehouse.getXMoving()));
        queryStates.append(String.format(",assert_once(y_moving(%d))",warehouse.getYMoving()));
        queryStates.append(String.format(",assert_once(z_moving(%d))",warehouse.getZMoving()));
        
        //System.out.println("query=" + queryState.toString()); //user this to test if ok
        String encodedStates = URLEncoder.encode(queryStates.toString(), StandardCharsets.UTF_8);
        
        String result = this.executePrologQuery("execute_remote_query?query=" + encodedStates);
        //System.out.println(result);
    }
    
        
    public void run() {
        while (!interrupted) {
            try{
                updateKnowledgeBase();
                invokeDispatcher();
                Thread.yield();
            }catch(Exception e) {
                e.printStackTrace();
            }
        }
        
        // REMAINING CODE HEHE (next slides)
    }
    
    
    public void invokeDispatcher()
    {
        String result = this.executePrologQuery("query_dispatcher_json");
        if(!result.equalsIgnoreCase("[]")){
            JSONArray jsonArray = new JSONArray(result);
            
            for( int i=0; i < jsonArray.length(); i++) {
                JSONObject jsonObject = jsonArray.getJSONObject(i);
                String action = jsonObject.getString("action_name");
                executeAction(action);
            }
        }
    }
    
    public void executeAction(String action)
    {
        if(action.equalsIgnoreCase("move_x_right")){
            warehouse.moveXRight();
        }
        else if(action.equalsIgnoreCase("move_x_left")){
            warehouse.moveXLeft();
        }
        else if(action.equalsIgnoreCase("stop_x")){
            warehouse.stopX();
        }
        else{
            System.out.printf("Dispatcher: Action %s means nothing to me. Go away! \n", action);
        }
        
        System.out.println("Executed action: " + action);
    }
    
    public synchronized JSONObject obtainSensorInformation(){
        JSONObject jsonObj = new JSONObject();
        jsonObj.put("x", warehouse.getXPosition());
        jsonObj.put("y", warehouse.getXPosition());
        jsonObj.put("z", warehouse.getXPosition());
        
        jsonObj.put("x_moving", warehouse.getXMoving());
        jsonObj.put("y_moving", warehouse.getXPosition());
        jsonObj.put("z_moving", warehouse.getXPosition());
        
        return jsonObj;
    }

}
