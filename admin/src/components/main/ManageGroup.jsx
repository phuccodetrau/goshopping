import React, {useState, useEffect} from "react";
import Navigator from "../Hung/Navigator";
import axios from "axios";
import SearchBoard from "../Hung/SearchBoard";
import PaginatedTable from "./Table_Search";
function ManageGroup(){
    var i = 1;
    const [groups, setGroups] = useState([]);
    useEffect(() => {
        const getGroups = async () => {
            try{
                const res = await axios.get("http://localhost:3000/admin/get_all_group");
                setGroups(res.data.groups);
                console.log(res.data);
            }catch(error){
                console.log(error.message);
            }
        }
       
        getGroups();
    }, [])
    return (
        <div id="wrapper">
        <Navigator></Navigator>
        <div className="d-flex flex-column" id="content-wrapper">
            <div id="content">
                <SearchBoard></SearchBoard>
                <div className="container-fluid">
                    <h3 className="text-dark mb-4"><strong>MANAGE GROUPS</strong></h3>
                    <div className="card shadow">
                        <div className="card-header py-3">
                            <p className="text-primary m-0 fw-bold">All groups</p>
                        </div>
                        <PaginatedTable datas={groups} title={["Group Id", "Group Name","Number User",'Number Food']} filter={"Group Name"} link={"managegroup"}></PaginatedTable>
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

export default ManageGroup;