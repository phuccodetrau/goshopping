import React, {useState, useEffect} from "react";
import Navigator from "../Hung/Navigator";
import axios from "axios";
import SearchBoard from "../Hung/SearchBoard";
import PaginatedTable from "./Table_Search";
function ManageUser(){
    var i = 1;
    const [users, setUsers] = useState([]);
    useEffect(() => {
        const getUsers = async () => {
            try{
                const res = await axios.get("http://localhost:3000/admin/get_all_user");
                setUsers(res.data.users);
              
            }catch(error){
                console.log(error.message);
            }
        }
       
        getUsers();
    }, [])
    return (
        <div id="wrapper">
        <Navigator></Navigator>
        <div className="d-flex flex-column" id="content-wrapper">
            <div id="content">
                <SearchBoard></SearchBoard>
                <div className="container-fluid">
                    <h3 className="text-dark mb-4"><strong>MANAGE USER</strong></h3>
                    <div className="card shadow">
                        <div className="card-header py-3">
                            <p className="text-primary m-0 fw-bold">All Users</p>
                        </div>
                        <PaginatedTable datas={users} title={["User Id", "User Name","User Email"]} filter={"User Name"} link={"manageuser"}></PaginatedTable>

                    </div>
                </div>
            </div>
            <footer className="bg-white sticky-footer">
                <div className="container my-auto">
                    <div className="text-center my-auto copyright"><span>Copyright © Brand 2024</span></div>
                </div>
            </footer>
        </div><a className="border rounded d-inline scroll-to-top" href="#page-top"><i className="fas fa-angle-up"></i></a>
    </div>
    )
}

export default ManageUser;