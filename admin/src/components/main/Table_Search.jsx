import React, { useState, useMemo } from "react";
import { useNavigate } from "react-router-dom";
const PaginatedTable = ( pros) => {
    var link=pros.link
    console.log(link)
    let navigate = useNavigate();
    function handleView(next_link){
        navigate(`/${link}`+`/${next_link}`)
    }
    const [currentPage, setCurrentPage] = useState(1);
    const [itemsPerPage, setItemsPerPage] = useState(10);
    const [searchTerm, setSearchTerm] = useState("");

    var datas=pros.datas
  
    var filter=pros.filter
    const filteredDatas = useMemo(() => {
        return datas.filter(data=>
            data[filter].toLowerCase().includes(searchTerm.toLowerCase())
        );
    }, [datas, searchTerm]);


    const totalPages = Math.ceil(filteredDatas.length / itemsPerPage);


    const currentDatas = useMemo(() => {
        const startIndex = (currentPage - 1) * itemsPerPage;
        const endIndex = startIndex + itemsPerPage;
        return filteredDatas.slice(startIndex, endIndex);
    }, [filteredDatas, currentPage, itemsPerPage]);


    const handlePageChange = (page) => {
        if (page > 0 && page <= totalPages) {
            setCurrentPage(page);
        }
    };

    return (
        <div className="table-container">
            <div className="row mb-3">
                <div className="col-md-6">
                    <label>
                        Show
                        <select
                            className="form-select form-select-sm d-inline-block w-auto mx-2"
                            value={itemsPerPage}
                            onChange={(e) => {
                                setItemsPerPage(parseInt(e.target.value));
                                setCurrentPage(1);
                            }}
                        >
                            <option value="10">10</option>
                            <option value="25">25</option>
                            <option value="50">50</option>
                            <option value="100">100</option>
                        </select>
                        entries
                    </label>
                </div>
                <div className="col-md-6 text-md-end">
                    <input
                        type="text"
                        className="form-control form-control-sm"
                        placeholder= {`Search By ${pros.filter}`}
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                </div>
            </div>

            <table className="table table-striped">
                <thead>
                    <tr>
                        <th>#</th>
                        {pros.title.map((title, index) => (
                        <th key={index}>{title}</th>
                    ))}
                        {!pros.detail&&(<th>Detail</th>)}
                    </tr>
                </thead>
                <tbody>
                    {currentDatas.map((data, index) => (
                        <tr>
                            <td key={index}>{(currentPage - 1) * itemsPerPage + index + 1}</td>
                            {pros.title.map((title,index1)=>
                                (<td key={index1}>{data[title]}</td>)
                            )}
                         {!pros.detail && 
                            
                            <td><button className="btn btn-primary btn-sm border rounded-pill" type="button" onClick={() => handleView(Object.entries(data)[0][1])}>View</button></td> 
                         }
                        </tr>
                    ))}
                </tbody>
            </table>

            <div className="d-flex justify-content-between align-items-center mt-3">
                <button
                    className="btn btn-sm btn-primary"
                    disabled={currentPage === 1}
                    onClick={() => handlePageChange(currentPage - 1)}
                >
                    Previous
                </button>

                <span>
                    Page {currentPage} of {totalPages}
                </span>

                <button
                    className="btn btn-sm btn-primary"
                    disabled={currentPage === totalPages}
                    onClick={() => handlePageChange(currentPage + 1)}
                >
                    Next
                </button>
            </div>
        </div>
    );
};

export default PaginatedTable;
