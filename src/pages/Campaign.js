import { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";
import ItemGroup from "../components/ItemGroup";
import ProductDetail from "../components/ProductDetail";
import ProductPicture from "../components/ProductPicture";
import { runScript } from "../utils/Common";
import * as campaignsService from "../services/campaign-service";

const Campaign = () => {
  const location = useLocation();
  const [campaigns, setCampaigns] = useState([]);
  const path = location.pathname.split("/")[2];
  const [campaign, setCampaign] = useState();

  useEffect(() => {
    const fetchCampaigns = async () => {
      const campaignsResponse = await campaignsService.getCampaigns();
      setCampaigns(campaignsResponse);
      console.log(campaigns);
      runScript();
    };
    fetchCampaigns();
  }, []);

  return (
    <>
      <section className="pt-3 pb-3 page-info section-padding border-bottom bg-white">
        <div className="container">
          <div className="row">
            <div className="col-md-12">
              <a href="#">
                <strong>
                  <span className="mdi mdi-home"></span> Home
                </strong>
              </a>{" "}
              <span className="mdi mdi-chevron-right"></span>{" "}
              <a href="#">Campaign</a>{" "}
              <span className="mdi mdi-chevron-right"></span> <a href="#">a</a>
            </div>
          </div>
        </div>
      </section>
      <section className="shop-single section-padding pt-3">
        <div className="container">
          <div className="row">
            <div className="col-md-6">
              <ProductPicture />
            </div>
            <div className="col-md-6">
              <ProductDetail />
            </div>
          </div>
        </div>
      </section>
      <ItemGroup
        title="Chiến dịch hot"
        listCampaigns={campaigns}
        type="hot"
      ></ItemGroup>
    </>
  );
};

export default Campaign;
