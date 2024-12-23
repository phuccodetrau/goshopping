import { Link } from "react-router-dom";
import image from '../../img/logo.png'
function Navigator(){
    return (
        <nav className="navbar align-items-start sidebar sidebar-dark accordion bg-gradient-primary p-0 navbar-dark">
   <div className="container-fluid d-flex flex-column p-0">
    <Link className="navbar-brand d-flex justify-content-center align-items-center sidebar-brand m-0" to="/homepage">
    <div className="sidebar-brand-icon ">
    <img src={image} alt="Logo" style={{ width: "30px", height: "30px" }} />
</div>
       <div className="sidebar-brand-text mx-3">
         <span>Go Shopping</span>
       </div>
    </Link>
     <hr className="sidebar-divider my-0" />
     <ul className="navbar-nav text-light" id="accordionSidebar">
       <li className="nav-item">
        <Link className="nav-link" to="/homepage">
        <i className="fas fa-tachometer-alt"></i>
           <span>Dashboard</span>
        </Link>
       </li>
       <li className="nav-item dropdown">
         <a className="dropdown-toggle nav-link" aria-expanded="false" data-bs-toggle="dropdown" href="/login">
           <i className="fas fa-user" style={{fontSize:"13px"}}></i>&nbsp;User Management </a>
         <div className="dropdown-menu">
           
           <Link className="dropdown-item" to="/manageuser" style={{paddingLeft:"30px"}}>
             <i className="fas fa-bars"></i>&nbsp;Manage all </Link>
         </div>
       </li>
       <li className="nav-item dropdown">
         <a className="dropdown-toggle nav-link" aria-expanded="false" data-bs-toggle="dropdown" href="/login">
           <i className="fas fa-users" style={{fontSize:"13px"}}></i>&nbsp;Group Management </a>
         <div className="dropdown-menu">
             <Link className="dropdown-item" style={{paddingLeft:"30px"}} to="/managegroup">
             <i className="fas fa-bars"></i>&nbsp;Manage all </Link>
         </div>
       </li>
      
       <li className="nav-item"></li>
       <li className="nav-item"></li>
       <li className="nav-item"></li>
       
     </ul>
     
   </div>
 </nav>
    );
}
export default Navigator;