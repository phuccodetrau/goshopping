import {React, useState ,useEffect} from 'react'
import axios from 'axios'
function Data(pros){
    
    return (
        <div className="row">
  <div className="col-md-6 col-xl-3 mb-4">
    <div className="card shadow border-start-primary py-2">
      <div className="card-body">
        <div className="row align-items-center no-gutters">
          <div className="col me-2">
            <div className="text-uppercase text-primary fw-bold text-xs mb-1">
              <span>Total Users</span>
            </div>
            <div className="text-dark fw-bold h5 mb-0">
              <span>{pros.number_user?pros.number_user:""}</span>
            </div>
          </div>
          <div className="col-auto">
            <i className="fas fa-user-circle fa-2x text-gray-300"></i>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div className="col-md-6 col-xl-3 mb-4">
    <div className="card shadow border-start-success py-2">
      <div className="card-body">
        <div className="row align-items-center no-gutters">
          <div className="col me-2">
            <div className="text-uppercase text-success fw-bold text-xs mb-1">
              <span>Total Groups</span>
            </div>
            <div className="text-dark fw-bold h5 mb-0">
              <span>{pros.number_group?pros.number_group:""}</span>
            </div>
          </div>
          <div className="col-auto">
            <i className="fas fa-users fa-2x text-gray-300"></i>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div className="col-md-6 col-xl-3 mb-4">
    <div className="card shadow border-start-info py-2">
      <div className="card-body">
        <div className="row align-items-center no-gutters">
          <div className="col me-2">
            <div className="text-uppercase text-info fw-bold text-xs mb-1">
              <span>Avg Member In Group</span>
            </div>
            <div className="row g-0 align-items-center">
              <div className="col-auto">
                <div className="text-dark fw-bold h5 mb-0 me-3">
                  <span>{pros.number_member_in_group?pros.number_member_in_group:""}</span>
                </div>
              </div>
              
            </div>
          </div>
          <div className="col-auto">
            <i className="fas fa-clipboard-list fa-2x text-gray-300"></i>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div className="col-md-6 col-xl-3 mb-4">
    <div className="card shadow border-start-warning py-2">
      <div className="card-body">
        <div className="row align-items-center no-gutters">
          <div className="col me-2">
            <div className="text-uppercase text-warning fw-bold text-xs mb-1">
              <span>Avg Food In Group</span>
            </div>
            <div className="text-dark fw-bold h5 mb-0">
              <span>{pros.number_food_in_group?pros.number_food_in_group:""}</span>
            </div>
          </div>
          <div className="col-auto">
            <i className="fas fa-utensils fa-2x text-gray-300"></i>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
    );
}
export default Data