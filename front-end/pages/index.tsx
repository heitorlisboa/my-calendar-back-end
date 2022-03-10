import Head from "next/head";
import type { NextPage } from "next";

import styles from "../src/styles/pages/Home.module.scss";

const Home: NextPage = () => {
  return (
    <>
      <Head>
        <title>MyCalendar</title>
      </Head>

      <h1>MyCalendar</h1>
    </>
  );
};

export default Home;
