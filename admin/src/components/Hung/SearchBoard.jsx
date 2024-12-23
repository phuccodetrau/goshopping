import Persion from "./Persion";
function SearchBoard(){
  return (
    <nav className="navbar navbar-expand bg-white shadow mb-4 topbar static-top navbar-light">
    <div className="container-fluid"><button className="btn btn-link d-md-none rounded-circle me-3" id="sidebarToggleTop" type="button"><i className="fas fa-bars"></i></button>
        
        <ul className="navbar-nav flex-nowrap ms-auto">
            <div className="d-none d-sm-block topbar-divider"></div>
            <Persion></Persion>
        </ul>
    </div>
    </nav>
  );
};
export default SearchBoard;