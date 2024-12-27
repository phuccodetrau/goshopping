
import { useState } from "react";
import HomePage from "./HomePage";
import Login from "./Login";
import React from "react";
import UserDetail from "./main/UserDetail";
import GroupDetail from "./main/GroupDetail";
import ManageGroup from "./main/ManageGroup";
import {BrowserRouter, Route,Navigate , Routes} from 'react-router-dom'
import ManageUser from "./main/ManageUser";
function App() {
	const [admin, setAdmin] = useState("");
    function changeAdmin(adminId){
       setAdmin(adminId);
	};
	return (
		<React.StrictMode>
    <BrowserRouter>
      <Routes>
        <Route index element={<Login admin={admin} state={changeAdmin} />} />
        <Route path='/login' element={<Login admin={admin} state={changeAdmin}></Login>}> </Route>
        <Route path='/homepage' element={(admin!=="")?<HomePage admin={admin} state={changeAdmin}></HomePage>:<Navigate to='/login'></Navigate>}></Route>
        <Route path='/manageuser/:userID' element={(admin!=="")?<UserDetail admin={admin} state={changeAdmin}></UserDetail>:<Navigate to='/login'></Navigate>}></Route>
        <Route path="/manageuser" element={(admin!=="")?<ManageUser admin={admin} state={changeAdmin}></ManageUser>:<Navigate to ='/login'></Navigate>}></Route>
        <Route path='/managegroup/:groupID' element={(admin!=="")?<GroupDetail admin={admin} state={changeAdmin}></GroupDetail>:<Navigate to='/login'></Navigate>}></Route>
        <Route path='/managegroup' element={(admin!=="")?<ManageGroup admin={admin} state={changeAdmin}></ManageGroup>:<Navigate to='/login'></Navigate>}></Route>
      </Routes>
    </BrowserRouter>
    </React.StrictMode>
	);
}

export default App;