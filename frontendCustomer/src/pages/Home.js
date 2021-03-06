import CenterBanner from "../components/home/CenterBanner";
import CampaignSlider from "../components/campaign/CampaignSlider";
import TopCategory from "../components/home/TopCategory";
import { runCaroselScript } from "../utils/Common";
import { useState, useEffect } from "react";
import TopBanner from "../components/home/TopBanner";
import campaignsApi from "../apis/campaignsApi";
import categoriesApi from "../apis/categoriesApi";
import cartApi from "../apis/cartApi";
import { useDispatch, useSelector } from "react-redux";
import { setCart } from "../state_manager_redux/cart/cartSlice";
import { Button, notification, Result } from "antd";
import { useNavigate, useSearchParams } from "react-router-dom";
import { setLocation } from "../state_manager_redux/location/locationSlice";
import userApi from "../apis/userApi";
import { setUser } from "../state_manager_redux/user/userSlice";
import LoadingPage from "./LoadingPage";

const Home = () => {
  const [weeklyCampaigns, setWeeklyCampaigns] = useState([]);
  const [hotCampaigns, setHotCampaign] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [noCampaign, setNoCampaign] = useState(false);
  const [networkErr, setNetworkErr] = useState(false);
  const [reload, setReload] = useState(true);
  const address = useSelector((state) => state.location);
  const user = useSelector((state) => state.user);
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const code = searchParams.get("code");
  const zoneId = useSelector((state) => state.zone);
  const [loginByCodeFlag, setLoginByCodeFlag] = useState(false);

  useEffect(() => {
    const loginByCode = async () => {
      await userApi
        .loginByCode(code)
        .then((result) => {
          if (result && result.user.role === "customer") {
            const setUserAction = setUser({ ...result });
            dispatch(setUserAction);
            if (result.user.address !== null && result.user.address !== "") {
              const setLocationAction = setLocation({
                location: result.user.address,
              });
              dispatch(setLocationAction);
            }
          }
        })
        .catch((err) => {
          if (err.message === "Network Error") {
            notification.error({
              duration: 3,
              message: "M???t k???t n???i m???ng!",
              style: { fontSize: 16 },
            });
          }
          if (address === null) navigate("/page-not-found");
        });
    };
    if (!loginByCodeFlag) {
      setLoginByCodeFlag(true);
      code && loginByCode();
    }
    if (address === null && code === null) {
      navigate("/getStarted");
    }
  }, []);
  // Get cart from server
  useEffect(() => {
    const fetchCartItems = async () => {
      const cartItemsResponse = await cartApi
        .getAll(user.id)
        .catch((err) => {});
      if (cartItemsResponse !== undefined && cartItemsResponse !== null) {
        const action = setCart(cartItemsResponse);
        dispatch(action);
      }
    };
    if (user !== null) fetchCartItems();
  }, []);

  // Get campaign and categories
  useEffect(() => {
    const fetchData = async () => {
      let noCampaignCount = 0;
      setNoCampaign(false);
      setNetworkErr(false);
      setLoading(true);
      //FetchCategory
      await categoriesApi
        .getAll()
        .then((result) => {
          setCategories(result.data);
        })
        .catch((err) => {
          setNetworkErr(true);
        });
      const params1 = {
        "delivery-zone-id": parseInt(zoneId),
        type: "H??ng tu???n",
        page: 1,
        size: 10,
      };
      await campaignsApi
        .getAll(params1)
        .then((result) => {
          if (result !== null && result !== undefined) {
            setWeeklyCampaigns(result.data);
            return result;
          }
        })
        .catch((err) => {
          if (err.message === "Network Error") {
            notification.error({
              duration: 3,
              message: "M???t k???t n???i m???ng!",
              style: { fontSize: 16 },
            });
            setNetworkErr(true);
          } else if (err.response.status === 400) {
            noCampaignCount = noCampaignCount + 1;
          } else {
            notification.error({
              duration: 3,
              message: "C?? l???i x???y ra trong qu?? tr??nh x??? l??!",
              style: { fontSize: 16 },
            });
            setNetworkErr(true);
          }
        });
      const params2 = {
        "delivery-zone-id": parseInt(zoneId),
        type: "S??? ki???n",
        page: 1,
        size: 10,
      };
      await campaignsApi
        .getAll(params2)
        .then((result) => {
          if (result !== null && result !== undefined) {
            setHotCampaign(result.data);
            return result;
          }
        })
        .catch((err) => {
          if (err.message === "Network Error") {
            notification.error({
              duration: 3,
              message: "M???t k???t n???i m???ng!",
              style: { fontSize: 16 },
            });
            setNetworkErr(true);
          } else if (err.response.status === 400) {
            noCampaignCount = noCampaignCount + 1;
          } else {
            notification.error({
              duration: 3,
              message: "C?? l???i x???y ra trong qu?? tr??nh x??? l??!",
              style: { fontSize: 16 },
            });
            setNetworkErr(true);
          }
        });
      if (noCampaignCount === 2) {
        notification.error({
          duration: 2,
          message: "Kh??ng t???n t???i chi???n d???ch h??? tr??? v??? tr?? c???a b???n!",
          style: { fontSize: 16 },
        });
        setNoCampaign(true);
      }
      runCaroselScript();
      setLoading(false);
    };

    if (zoneId !== null) {
      fetchData();
    } else {
      setLoading(false);
    }
  }, [reload, zoneId]);

  return (
    <>
      {networkErr ? (
        <Result
          status="error"
          title="???? c?? l???i x???y ra!"
          subTitle="R???t ti???c ???? c?? l???i x???y ra trong qu?? tr??nh t???i d??? li???u, qu?? kh??ch vui l??ng ki???m tra l???i k???t n???i m???ng v?? th??? l???i."
          extra={[
            <Button
              type="primary"
              key="console"
              onClick={() => {
                setReload(!reload);
              }}
            >
              T???i l???i
            </Button>,
          ]}
        ></Result>
      ) : (
        <>
          <TopBanner />
          {loading ? (
            <LoadingPage />
          ) : !noCampaign ? (
            <>
              <TopCategory categories={categories}></TopCategory>
              <CampaignSlider
                title="Chi???n d???ch h??ng tu???n"
                listCampaigns={weeklyCampaigns}
                type="H??ng tu???n"
              ></CampaignSlider>
              <CenterBanner />
              <CampaignSlider
                title="Chi???n d???ch s??? ki???n"
                listCampaigns={hotCampaigns}
                type="S??? ki???n"
              ></CampaignSlider>
            </>
          ) : (
            <div className="d-flex justify-content-center">
              <Result
                status="warning"
                title="Kh??ng t???n t???i chi???n d???ch h??? tr??? v??? tr?? c???a b???n!"
              />
            </div>
          )}
        </>
      )}
    </>
  );
};

export default Home;
