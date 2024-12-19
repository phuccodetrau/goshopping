import React from "react";
import { useParams } from "react-router-dom";
import { useState, useEffect } from "react";
import { useNavigate,useLocation } from "react-router-dom";
import axios from "axios";
import Navigator from "../Hung/Navigator";
import SearchBoard from "../Hung/SearchBoard";
import Footer from "../Hung/Footer";
import PaginatedTable from "./Table_Search";
function UserDetail(){
    var i = 1;
    let navigate = useNavigate();
    function handleBack(){
        navigate("/manageuser");
    }
    
    
   
    const { userID } = useParams();
    const [users, setUser] = useState({})
    const [name,setName]=useState("")
    useEffect (() => {
        const getUserDetail = async () => {
            try{
                const res = await axios.post("http://localhost:3000/admin/get_one_user", {userID:userID});
                
                setUser(res.data.user_info.group);
                setName(res.data.user_info.name)
                
               
                
            }catch(error){
                console.log(error.message);
            }
        }
        getUserDetail();
    },[])
    return (
        <div id="wrapper">
        <Navigator></Navigator>
        <div className="d-flex flex-column" id="content-wrapper">
            <div id="content">
                <SearchBoard></SearchBoard>
                <div className="container-fluid">
                <h3 className="text-dark mb-4">{name}</h3>
                </div>
                
                { users.length > 0 &&
                <div className="container-fluid">
                    
        
                    <div className="card shadow">
                        <div className="card-header py-3">
                            <p className="text-primary m-0 fw-bold">Group Detail</p>
                        </div>
                        <PaginatedTable datas={users} title={["Group ID", "Group Name","Number Member", "Role"]} filter={"Group Name"} link={"managegroup"}></PaginatedTable>

                       
                    </div>
                </div>
                
            }
           
            </div>
            
            <Footer></Footer>
        </div><a className="border rounded d-inline scroll-to-top" href="#page-top"><i className="fas fa-angle-up"></i></a>
    </div>
    )
}

export default UserDetail;