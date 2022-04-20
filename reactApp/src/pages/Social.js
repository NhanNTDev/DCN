import { Button, notification, Pagination, Result } from "antd";
import { reload } from "firebase/auth";
import { useEffect, useState } from "react";
import { useSelector } from "react-redux";
import postApi from "../apis/postApis";
import Follow from "../components/social/Follow";
import Post from "../components/social/Post";
import LoadingPage from "./LoadingPage";

const Social = () => {
  const [listPost, setListPost] = useState([]);
  const [page, setPage] = useState(1);
  const [totalPost, setTotalPost] = useState(1);
  const [loadErr, setLoadErr] = useState(false);
  const user = useSelector((state) => state.user);
  const [loading, setLoading] = useState(true);
  const [reload, setReload] = useState(true);
  useEffect(() => {
    const getPost = async () => {
      setLoadErr(false);
      await postApi
        .getPost({ userId: user.id, page: page })
        .then((result) => {
          setTotalPost(result.metadata.total);
          setListPost(result.data);
          console.log(result);
        })
        .catch((err) => {
          if (err.message === "Network Error") {
            notification.error({
              duration: 3,
              message: "Mất kết nối mạng!",
              style: { fontSize: 16 },
            });
            setLoadErr(true);
          } else {
            notification.error({
              duration: 2,
              message: "Có lỗi xảy ra trong quá trình xử lý!",
              style: { fontSize: 16 },
            });
          }
          setLoadErr(true);
        });
      setLoading(false);
    };
    getPost();
  }, [page, reload]);
  return (
    <>
      {loading ? (
        <LoadingPage />
      ) : (
        <>
          {" "}
          {loadErr ? (
            <Result
              status="error"
              title="Đã có lỗi xảy ra!"
              subTitle="Rất tiếc đã có lỗi xảy ra trong quá trình tải dữ liệu, quý khách vui lòng kiểm tra lại kết nối mạng và thử lại."
              extra={[
                <Button
                  type="primary"
                  key="console"
                  onClick={() => {
                    setReload(!reload);
                  }}
                >
                  Tải lại
                </Button>,
              ]}
            ></Result>
          ) : (
            <div className="container">
              <h1
                className="d-flex justify-content-center"
                style={{ color: "lightBlue" }}
              >
                Cùng nhau đi chợ nào!
              </h1>
              <div className="row">
                <div className="col-sm-8">
                  <div className="container-fluid">
                    {Object.entries(listPost).length !== 0 && listPost.map(post => <Post post={post}/> )}
                  </div>
                  <Pagination
                    className="d-flex justify-content-center"
                    total={totalPost}
                    size={10}
                    current={page}
                    onChange={(current) => {
                      setPage(current);
                    }}
                    style={{ marginTop: 30, marginBottom: 30 }}
                  />
                </div>
                <div className="col-sm-4">
                  <div className="container-fluid">
                    <Follow />
                  </div>
                </div>
              </div>
            </div>
          )}
        </>
      )}
    </>
  );
};

export default Social;
