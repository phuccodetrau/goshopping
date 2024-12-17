import React from "react";
import { useParams } from "react-router-dom";
import { useState, useEffect } from "react";
import { useNavigate,useLocation } from "react-router-dom";
import axios from "axios";
import Navigator from "../Hung/Navigator";
import SearchBoard from "../Hung/SearchBoard";
import Footer from "../Hung/Footer";
import PaginatedTable from "./Table_Search";
function GroupDetail(){
    var i = 1;
    let location=useLocation();
    let navigate = useNavigate();
    function handleBack(){
        navigate("/managegroup");
    }
    function UserDetail(props){
        return (
            <tr>
                <td>{props.stt}</td>
                <td>{props.name}</td>
                <td>{props.email}</td>
                <td>{props.role}</td>
               
            </tr>
        )
    }
    function FoodDetail(props){
        return (
            <tr>
                <td>{props.stt}</td>
                <td>{props.name}</td>
                <td>{props.expireDate}</td>
                <td>{props.amount}</td>
                <td>{props.note}</td>
            </tr>
        )
    }
   
    const { groupID } = useParams();
    const [users, setUser] = useState({})
    const [foods, setFood] = useState([])
    useEffect (() => {
        const getGroupDetail = async () => {
            try{
                const res = await axios.post("http://localhost:3000/admin/get_one_group", {groupID:groupID});
                
                setUser(res.data.group.user);
              
                
                setFood(res.data.group.refrigerator);
                
            }catch(error){
                console.log(error.message);
            }
        }
        getGroupDetail();
    },[])
    return (
        <div id="wrapper">
        <Navigator></Navigator>
        <div className="d-flex flex-column" id="content-wrapper">
            <div id="content">
                <SearchBoard></SearchBoard>
                <div className="container-fluid">
                <h3 className="text-dark mb-4">Group Detail</h3>
                </div>
                
                { users.length > 0 &&
                <div className="container-fluid">
                    
        
                    <div className="card shadow">
                        <div className="card-header py-3">
                            <p className="text-primary m-0 fw-bold">User Detail</p>
                        </div>
                        <PaginatedTable datas={users} title={["User Id", "User Name","User Email","User Role"]} filter={"User Name"} link={"manageuser"}></PaginatedTable>

                    </div>
                </div>
                
            }
            <br>

            </br>  
            
            { foods.length > 0 &&
                <div className="container-fluid">
                    
        
                    <div className="card shadow">
                        <div className="card-header py-3">
                            <p className="text-primary m-0 fw-bold">Food Detail</p>
                        </div>
                        <PaginatedTable datas={foods} title={["Food Name", "Expire Date","Amount", "Note"]} filter={"Food Name"} link={""} detail={true}></PaginatedTable>

                        
                       
                    </div>
                </div>
                
            }</div>
            
            <Footer></Footer>
        </div><a className="border rounded d-inline scroll-to-top" href="#page-top"><i className="fas fa-angle-up"></i></a>
    </div>
    )
}

export default GroupDetail;