
import React from "react";
import { useState } from "react";
import axios from 'axios'
import { useNavigate } from 'react-router-dom';
import avatar from "../img/logo.png"
const URL="http://localhost:3000";
function Login(pros){
    let navigate=useNavigate();
    const [admin, stateAdmin]=useState({
       email:"",
       password:""
    });
    function update(e){
       stateAdmin(previousState=>{
        return {...previousState, [e.target.name]:e.target.value}
       });
    };
    async function  onLogin(e){
        e.preventDefault();
        try {
            const res= await axios.post(URL+"/admin/login", {
                email:admin.email,
                password:admin.password
            });
         
            if(res.data.status===true){
                pros.state(res.data.admin._id);
                navigate("/homepage");
            }
            else{
                alert("Mật khẩu không chính xác hoặc tài khoản chưa đăng kí");
            }
            console.log(res.data);
        } catch (error) {
            console.log(error);
        }
    }
    return (
        <div className="bg-gradient-primary">
            <div className="container">
        <div className="row justify-content-center">
            <div className="col-md-9 col-lg-12 col-xl-10">
                <div className="card shadow-lg o-hidden border-0 my-5">
                    <div className="card-body p-0">
                        <div className="row">
                            <div className="col-lg-6 d-none d-lg-flex">
                                <div className="flex-grow-1 bg-login-image" style={{backgroundImage: "url(" + avatar+ ")"}}></div>
                            </div>
                            <div className="col-lg-6">
                                <div className="p-5">
                                    <div className="text-center">
                                        <h4 className="text-dark mb-4">Welcome Back!</h4>
                                    </div>
                                    <form className="admin" onSubmit={onLogin}>
                                        <div className="mb-3"><input className="form-control form-control-admin" type="email" id="exampleInputEmail" aria-describedby="emailHelp" placeholder="Enter Email Address..." name="email" value={admin.email}  onChange={update}/>          
                                        </div>
                                        <div className="mb-3"><input className="form-control form-control-admin" type="password" id="exampleInputPassword" placeholder="Password" name="password" value={admin.password} onChange={update}/></div>
                                        <div className="mb-3">
                                            
                                        </div>
                                        <button className="btn btn-primary d-block btn-admin w-100" type="submit" >Login</button>

                                        <hr/>
                                        
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
        </div>
        
    );
}
export default Login;