import Head from "next/head";
import type { AppProps } from "next/app";

import "../src/styles/global/index.scss";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <Head>
        <meta charSet="utf-8" />
        <meta httpEquiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
        <meta
          name="description"
          content="MyCalendar é uma aplicação simples de calendário para ajudar na organização das tarefas do dia a dia"
        />
      </Head>
      <Component {...pageProps} />
    </>
  );
}

export default MyApp;
