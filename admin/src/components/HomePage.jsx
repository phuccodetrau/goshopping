import Navigator from "./Hung/Navigator";
import Data from "./Hung/Data";
import RegisterPerDay from "./Hung/RegisterPerDay";
import NewGroupPerDay from "./Hung/NewGroupPerDay";
import Footer from "./Hung/Footer";
import SearchBoard from './Hung/SearchBoard'

import { useState, useEffect } from "react";
import axios from 'axios'
function HomePage(props){
    const URL="http://localhost:3000"
    const [info,setInfo]=useState({});
    useEffect(()=>{
      const getInfo=async()=>{
        try{
            const res =await axios.get(`${URL}/admin/get_admin_info`);
            setInfo(res.data.info);
            
        }catch(error){
            console.log(error.message);
        }
      };
      getInfo();
    },[]);
    return (
        <div  id="page-top">
            <div id="wrapper">
            <Navigator state={props.state}></Navigator>
        <div className="d-flex flex-column" id="content-wrapper">
            <div id="content" >
                <SearchBoard></SearchBoard>
                <div className="container-fluid">
                    <div className="d-sm-flex justify-content-between align-items-center mb-4">
                        <h3 className="text-dark mb-0">Dashboard</h3>
                    </div>
                    <div className="row"  >
                    <Data number_user={info.number_user} number_group={info.number_group} number_member_in_group={info.number_member_in_group} number_food_in_group={info.number_food_in_group}></Data>
                    <RegisterPerDay new_users_per_day={info.new_users_per_day}></RegisterPerDay>
                    
                    <NewGroupPerDay new_groups_per_day={info.new_groups_per_day}></NewGroupPerDay>
                    </div>
                    
                </div>
            </div>
            <Footer></Footer>
        </div>
        <a className="border rounded d-inline scroll-to-top" href="#page-top"><i className="fas fa-angle-up"></i></a>
    </div>
        </div>
    );
}
export default HomePage;