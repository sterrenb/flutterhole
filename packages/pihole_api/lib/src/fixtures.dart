// TODO move out of src, into test

final adminHtmlString = '''<!DOCTYPE html>
<!-- Pi-hole: A black hole for Internet advertisements
*  (c) 2017 Pi-hole, LLC (https://pi-hole.net)
*  Network-wide ad blocking via your own hardware.
*
*  This file is copyright under the latest version of the EUPL.
*  Please see LICENSE file for your rights under this license. -->
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta
      http-equiv="Content-Security-Policy"
      content="default-src 'none'; base-uri 'none'; child-src 'self'; form-action 'self'; frame-src 'self'; font-src 'self'; connect-src 'self'; img-src 'self'; manifest-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
    />
    <!-- Usually browsers proactively perform domain name resolution on links that the user may choose to follow. We disable DNS prefetching here -->
    <meta http-equiv="x-dns-prefetch-control" content="off" />
    <meta http-equiv="cache-control" content="max-age=60,private" />
    <!-- Tell the browser to be responsive to screen width -->
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Pi-hole - raspberrypi</title>

    <link
      rel="apple-touch-icon"
      href="img/favicons/apple-touch-icon.png"
      sizes="180x180"
    />
    <link
      rel="icon"
      href="img/favicons/favicon-32x32.png"
      sizes="32x32"
      type="image/png"
    />
    <link
      rel="icon"
      href="img/favicons/favicon-16x16.png"
      sizes="16x16"
      type="image/png"
    />
    <link rel="manifest" href="img/favicons/manifest.json" />
    <link
      rel="mask-icon"
      href="img/favicons/safari-pinned-tab.svg"
      color="#367fa9"
    />
    <link rel="shortcut icon" href="img/favicons/favicon.ico" />
    <meta name="msapplication-TileColor" content="#367fa9" />
    <meta
      name="msapplication-TileImage"
      content="img/favicons/mstile-150x150.png"
    />
    <meta name="theme-color" content="#367fa9" />

    <link
      rel="stylesheet"
      href="style/vendor/SourceSansPro/SourceSansPro.css?v=1612277927"
    />
    <link
      rel="stylesheet"
      href="style/vendor/bootstrap/css/bootstrap.min.css?v=1612277927"
    />
    <link
      rel="stylesheet"
      href="style/vendor/datatables.min.css?v=1612277927"
    />
    <link
      rel="stylesheet"
      href="style/vendor/daterangepicker.min.css?v=1612277927"
    />
    <link rel="stylesheet" href="style/vendor/AdminLTE.min.css?v=1612277927" />
    <link rel="stylesheet" href="style/vendor/select2.min.css?v=1612277927" />

    <link rel="stylesheet" href="style/pi-hole.css?v=1612277927" />
    <link rel="stylesheet" href="style/themes/default-light.css?v=1612277927" />
    <noscript
      ><link rel="stylesheet" href="style/vendor/js-warn.css?v=1612277927"
    /></noscript>

    <script src="scripts/vendor/jquery.min.js?v=1612277927"></script>
    <script src="style/vendor/bootstrap/js/bootstrap.min.js?v=1612277927"></script>
    <script src="scripts/vendor/adminlte.min.js?v=1612277927"></script>
    <script src="scripts/vendor/bootstrap-notify.min.js?v=1612277927"></script>
    <script src="scripts/vendor/select2.min.js?v=1612277927"></script>
    <script src="scripts/vendor/datatables.min.js?v=1612277927"></script>
    <script src="scripts/vendor/moment.min.js?v=1612277927"></script>
    <script src="scripts/vendor/Chart.min.js?v=1612277927"></script>
    <script src="style/vendor/font-awesome/js/all.min.js?v=1612277927"></script>
  </head>
  <body class="hold-transition sidebar-mini layout-boxed">
    <noscript>
      <!-- JS Warning -->
      <div>
        <input type="checkbox" id="js-hide" />
        <div class="js-warn" id="js-warn-exit">
          <h1>JavaScript Is Disabled</h1>
          <p>JavaScript is required for the site to function.</p>
          <p>
            To learn how to enable JavaScript click
            <a
              href="https://www.enable-javascript.com/"
              rel="noopener"
              target="_blank"
              >here</a
            >
          </p>
          <label for="js-hide">Close</label>
        </div>
      </div>
      <!-- /JS Warning -->
    </noscript>

    <!-- Send token to JS -->
    <div id="enableTimer" hidden></div>
    <div class="wrapper">
      <header class="main-header">
        <!-- Logo -->
        <a href="index.php" class="logo">
          <!-- mini logo for sidebar mini 50x50 pixels -->
          <span class="logo-mini">P<strong>h</strong></span>
          <!-- logo for regular state and mobile devices -->
          <span class="logo-lg">Pi-<strong>hole</strong></span>
        </a>
        <!-- Header Navbar: style can be found in header.less -->
        <nav class="navbar navbar-static-top">
          <!-- Sidebar toggle button-->
          <a
            href="#"
            class="sidebar-toggle-svg"
            data-toggle="push-menu"
            role="button"
          >
            <i aria-hidden="true" class="fa fa-bars"></i>
            <span class="sr-only">Toggle navigation</span>
          </a>
          <div class="navbar-custom-menu">
            <ul class="nav navbar-nav">
              <li id="pihole-diagnosis" class="hidden">
                <a href="messages.php">
                  <i class="fa fa-exclamation-triangle"></i>
                  <span
                    class="label label-warning"
                    id="pihole-diagnosis-count"
                  ></span>
                </a>
              </li>
              <li>
                <p class="navbar-text">
                  <span class="hidden-xs hidden-sm">hostname:</span>
                  <code>raspberrypi</code>
                </p>
              </li>
              <li class="dropdown user user-menu">
                <a
                  href="#"
                  class="dropdown-toggle"
                  data-toggle="dropdown"
                  aria-expanded="false"
                >
                  <img
                    src="img/logo.svg"
                    class="user-image"
                    alt="Pi-hole logo"
                    style="border-radius: 0"
                    width="25"
                    height="25"
                  />
                  <span class="hidden-xs">Pi-hole</span>
                </a>
                <ul class="dropdown-menu">
                  <!-- User image -->
                  <li class="user-header">
                    <img
                      src="img/logo.svg"
                      alt="Pi-hole Logo"
                      style="border: 0"
                      width="90"
                      height="90"
                    />
                    <p>
                      Open Source Ad Blocker
                      <small>Designed For Raspberry Pi</small>
                    </p>
                  </li>
                  <!-- Menu Body -->
                  <li class="user-body">
                    <div class="row">
                      <div class="col-xs-4 text-center">
                        <a
                          class="btn-link"
                          href="https://github.com/pi-hole"
                          rel="noopener"
                          target="_blank"
                          >GitHub</a
                        >
                      </div>
                      <div class="col-xs-4 text-center">
                        <a
                          class="btn-link"
                          href="https://pi-hole.net/"
                          rel="noopener"
                          target="_blank"
                          >Website</a
                        >
                      </div>
                      <div class="col-xs-4 text-center">
                        <a
                          class="btn-link"
                          href="https://github.com/pi-hole/pi-hole/releases"
                          rel="noopener"
                          target="_blank"
                          >Updates</a
                        >
                      </div>
                      <div id="sessiontimer" class="col-xs-12 text-center">
                        <strong
                          >Session is valid for
                          <span id="sessiontimercounter">0</span></strong
                        >
                      </div>
                    </div>
                  </li>
                  <!-- Menu Footer -->
                  <li class="user-footer">
                    <!-- PayPal -->
                    <div class="text-center">
                      <a
                        href="https://pi-hole.net/donate/"
                        rel="noopener"
                        target="_blank"
                      >
                        <img
                          src="img/donate.gif"
                          alt="Donate"
                          width="147"
                          height="47"
                        />
                      </a>
                    </div>
                  </li>
                </ul>
              </li>
            </ul>
          </div>
        </nav>
      </header>
      <!-- Left side column. contains the logo and sidebar -->
      <aside class="main-sidebar">
        <!-- sidebar: style can be found in sidebar.less -->
        <section class="sidebar">
          <!-- Sidebar user panel -->
          <div class="user-panel">
            <div class="pull-left image">
              <img
                src="img/logo.svg"
                alt="Pi-hole logo"
                width="45"
                height="67"
                style="height: 67px"
              />
            </div>
            <div class="pull-left info">
              <p>Status</p>
              <span id="status"
                ><i class="fa fa-circle text-green-light"></i> Active</span
              ><span id="temperature"
                ><i class="fa fa-fire text-vivid-blue"></i> Temp:&nbsp;<span
                  id="rawtemp"
                  hidden
                  >48.312</span
                ><span id="tempdisplay"></span
              ></span>
              <br />
              <span title="Detected 4 cores"
                ><i class="fa fa-circle text-green-light"></i>
                Load:&nbsp;&nbsp;0&nbsp;&nbsp;0&nbsp;&nbsp;0</span
              >
              <br />
              <span
                ><i class="fa fa-circle text-green-light"></i> Memory
                usage:&nbsp;&nbsp;21.4&thinsp;%</span
              >
            </div>
          </div>
          <!-- sidebar menu: : style can be found in sidebar.less -->
          <ul class="sidebar-menu" data-widget="tree">
            <li class="header text-uppercase">Main navigation</li>
            <!-- Home Page -->
            <li class="active">
              <a href="index.php">
                <i class="fa fa-fw fa-home"></i> <span>Dashboard</span>
              </a>
            </li>
            <!-- Login -->
            <li>
              <a href="index.php?login">
                <i class="fa fa-fw fa-user"></i> <span>Login</span>
              </a>
            </li>
            <!-- Donate -->
            <li>
              <a
                href="https://pi-hole.net/donate/"
                rel="noopener"
                target="_blank"
              >
                <i class="fab fa-fw fa-paypal"></i> <span>Donate</span>
              </a>
            </li>
            <!-- Docs -->
            <li>
              <a
                href="https://docs.pi-hole.net/"
                rel="noopener"
                target="_blank"
              >
                <i class="fa fa-fw fa-question-circle"></i>
                <span>Documentation</span>
              </a>
            </li>
          </ul>
        </section>
        <!-- /.sidebar -->
      </aside>
      <!-- Content Wrapper. Contains page content -->
      <div class="content-wrapper">
        <!-- Main content -->
        <section class="content">
          <!-- Sourceing CSS colors from stylesheet to be used in JS code -->
          <span class="queries-permitted"></span>
          <span class="queries-blocked"></span>
          <span class="graphs-grid"></span>
          <span class="graphs-ticks"></span>
          <!-- Small boxes (Stat box) -->
          <div class="row">
            <div class="col-lg-3 col-sm-6">
              <!-- small box -->
              <div
                class="small-box bg-green no-user-select"
                id="total_queries"
                title="only A + AAAA queries"
              >
                <div class="inner">
                  <p>
                    Total queries (<span id="unique_clients">-</span> clients)
                  </p>
                  <h3 class="statistic">
                    <span id="dns_queries_today">---</span>
                  </h3>
                </div>
                <div class="icon">
                  <i class="fas fa-globe-americas"></i>
                </div>
              </div>
            </div>
            <!-- ./col -->
            <div class="col-lg-3 col-sm-6">
              <!-- small box -->
              <div class="small-box bg-aqua no-user-select">
                <div class="inner">
                  <p>Queries Blocked</p>
                  <h3 class="statistic">
                    <span id="queries_blocked_today">---</span>
                  </h3>
                </div>
                <div class="icon">
                  <i class="fas fa-hand-paper"></i>
                </div>
              </div>
            </div>
            <!-- ./col -->
            <div class="col-lg-3 col-sm-6">
              <!-- small box -->
              <div class="small-box bg-yellow no-user-select">
                <div class="inner">
                  <p>Percent Blocked</p>
                  <h3 class="statistic">
                    <span id="percentage_blocked_today">---</span>
                  </h3>
                </div>
                <div class="icon">
                  <i class="fas fa-chart-pie"></i>
                </div>
              </div>
            </div>
            <!-- ./col -->
            <div class="col-lg-3 col-sm-6">
              <!-- small box -->
              <div
                class="small-box bg-red no-user-select"
                title="Blocking list updated 2 days, 14:55 (hh:mm) ago"
              >
                <div class="inner">
                  <p>Domains on Blocklist</p>
                  <h3 class="statistic">
                    <span id="domains_being_blocked">---</span>
                  </h3>
                </div>
                <div class="icon">
                  <i class="fas fa-list-alt"></i>
                </div>
              </div>
            </div>
            <!-- ./col -->
          </div>

          <div class="row">
            <div class="col-md-12">
              <div class="box" id="queries-over-time">
                <div class="box-header with-border">
                  <h3 class="box-title">Total queries over last 24 hours</h3>
                </div>
                <div class="box-body">
                  <div class="chart">
                    <canvas
                      id="queryOverTimeChart"
                      width="800"
                      height="140"
                    ></canvas>
                  </div>
                </div>
                <div class="overlay">
                  <i class="fa fa-sync fa-spin"></i>
                </div>
                <!-- /.box-body -->
              </div>
            </div>
          </div>

          <script src="scripts/pi-hole/js/utils.js?v=1612277927"></script>
          <script src="scripts/pi-hole/js/index.js?v=1612277927"></script>
        </section>
        <!-- /.content -->
      </div>
      <!-- Modal for custom disable time -->
      <div
        class="modal fade"
        id="customDisableModal"
        tabindex="-1"
        role="dialog"
        aria-labelledby="myModalLabel"
      >
        <div class="modal-dialog modal-sm" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <button
                type="button"
                class="close"
                data-dismiss="modal"
                aria-label="Close"
              >
                <span aria-hidden="true">&times;</span>
              </button>
              <h4 class="modal-title" id="myModalLabel">
                Custom disable timeout
              </h4>
            </div>
            <div class="modal-body">
              <div class="input-group">
                <input
                  id="customTimeout"
                  class="form-control"
                  type="number"
                  value="60"
                />
                <div class="input-group-btn" data-toggle="buttons">
                  <label class="btn btn-default">
                    <input id="selSec" type="radio" /> Secs
                  </label>
                  <label id="btnMins" class="btn btn-default active">
                    <input id="selMin" type="radio" /> Mins
                  </label>
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button
                type="button"
                class="btn btn-default"
                data-dismiss="modal"
              >
                Close
              </button>
              <button
                type="button"
                id="pihole-disable-custom"
                class="btn btn-primary"
                data-dismiss="modal"
              >
                Submit
              </button>
            </div>
          </div>
        </div>
      </div>
      <!-- /.content-wrapper -->

      <footer class="main-footer">
        <div class="row row-centered text-center">
          <div class="col-xs-12 col-sm-6">
            <strong
              ><a
                href="https://pi-hole.net/donate/"
                rel="noopener"
                target="_blank"
                ><i class="fa fa-heart text-red"></i> Donate</a
              ></strong
            >
            if you found this useful.
          </div>
        </div>

        <div class="row row-centered text-center version-info">
          <div class="col-xs-12 col-sm-8 col-md-6">
            <ul class="list-inline">
              <li>
                <strong>Pi-hole</strong>
                <a
                  href="https://github.com/pi-hole/pi-hole/releases/v5.2.4"
                  rel="noopener"
                  target="_blank"
                  >v5.2.4</a
                >
                &middot;
                <a
                  class="lookatme"
                  href="https://github.com/pi-hole/pi-hole/releases/latest"
                  rel="noopener"
                  target="_blank"
                  >Update available!</a
                >
              </li>
              <li>
                <strong>Web Interface</strong>
                <a
                  href="https://github.com/pi-hole/AdminLTE/releases/v5.3.2"
                  rel="noopener"
                  target="_blank"
                  >v5.3.2</a
                >
                &middot;
                <a
                  class="lookatme"
                  href="https://github.com/pi-hole/AdminLTE/releases/latest"
                  rel="noopener"
                  target="_blank"
                  >Update available!</a
                >
              </li>
              <li>
                <strong>FTL</strong>
                <a
                  href="https://github.com/pi-hole/FTL/releases/v5.6"
                  rel="noopener"
                  target="_blank"
                  >v5.6</a
                >
                &middot;
                <a
                  class="lookatme"
                  href="https://github.com/pi-hole/FTL/releases/latest"
                  rel="noopener"
                  target="_blank"
                  >Update available!</a
                >
              </li>
            </ul>
          </div>
        </div>
      </footer>
    </div>
    <!-- ./wrapper -->
    <script src="scripts/pi-hole/js/footer.js?v=1612277927"></script>
  </body>
</html>''';

final adminHtmlStringWithoutTags = '''<!DOCTYPE html>
<!-- Pi-hole: A black hole for Internet advertisements
*  (c) 2017 Pi-hole, LLC (https://pi-hole.net)
*  Network-wide ad blocking via your own hardware.
*
*  This file is copyright under the latest version of the EUPL.
*  Please see LICENSE file for your rights under this license. -->
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta
      http-equiv="Content-Security-Policy"
      content="default-src 'none'; base-uri 'none'; child-src 'self'; form-action 'self'; frame-src 'self'; font-src 'self'; connect-src 'self'; img-src 'self'; manifest-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
    />
    <!-- Usually browsers proactively perform domain name resolution on links that the user may choose to follow. We disable DNS prefetching here -->
    <meta http-equiv="x-dns-prefetch-control" content="off" />
    <meta http-equiv="cache-control" content="max-age=60,private" />
    <!-- Tell the browser to be responsive to screen width -->
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Pi-hole - raspberrypi</title>

    <link
      rel="apple-touch-icon"
      href="img/favicons/apple-touch-icon.png"
      sizes="180x180"
    />
    <link
      rel="icon"
      href="img/favicons/favicon-32x32.png"
      sizes="32x32"
      type="image/png"
    />
    <link
      rel="icon"
      href="img/favicons/favicon-16x16.png"
      sizes="16x16"
      type="image/png"
    />
    <link rel="manifest" href="img/favicons/manifest.json" />
    <link
      rel="mask-icon"
      href="img/favicons/safari-pinned-tab.svg"
      color="#367fa9"
    />
    <link rel="shortcut icon" href="img/favicons/favicon.ico" />
    <meta name="msapplication-TileColor" content="#367fa9" />
    <meta
      name="msapplication-TileImage"
      content="img/favicons/mstile-150x150.png"
    />
    <meta name="theme-color" content="#367fa9" />

    <link
      rel="stylesheet"
      href="style/vendor/SourceSansPro/SourceSansPro.css?v=1612277927"
    />
    <link
      rel="stylesheet"
      href="style/vendor/bootstrap/css/bootstrap.min.css?v=1612277927"
    />
    <link
      rel="stylesheet"
      href="style/vendor/datatables.min.css?v=1612277927"
    />
    <link
      rel="stylesheet"
      href="style/vendor/daterangepicker.min.css?v=1612277927"
    />
    <link rel="stylesheet" href="style/vendor/AdminLTE.min.css?v=1612277927" />
    <link rel="stylesheet" href="style/vendor/select2.min.css?v=1612277927" />

    <link rel="stylesheet" href="style/pi-hole.css?v=1612277927" />
    <link rel="stylesheet" href="style/themes/default-light.css?v=1612277927" />
    <noscript
      ><link rel="stylesheet" href="style/vendor/js-warn.css?v=1612277927"
    /></noscript>

    <script src="scripts/vendor/jquery.min.js?v=1612277927"></script>
    <script src="style/vendor/bootstrap/js/bootstrap.min.js?v=1612277927"></script>
    <script src="scripts/vendor/adminlte.min.js?v=1612277927"></script>
    <script src="scripts/vendor/bootstrap-notify.min.js?v=1612277927"></script>
    <script src="scripts/vendor/select2.min.js?v=1612277927"></script>
    <script src="scripts/vendor/datatables.min.js?v=1612277927"></script>
    <script src="scripts/vendor/moment.min.js?v=1612277927"></script>
    <script src="scripts/vendor/Chart.min.js?v=1612277927"></script>
    <script src="style/vendor/font-awesome/js/all.min.js?v=1612277927"></script>
  </head>
  <body class="hold-transition sidebar-mini layout-boxed">
    <noscript>
      <!-- JS Warning -->
      <div>
        <input type="checkbox" id="js-hide" />
        <div class="js-warn" id="js-warn-exit">
          <h1>JavaScript Is Disabled</h1>
          <p>JavaScript is required for the site to function.</p>
          <p>
            To learn how to enable JavaScript click
            <a
              href="https://www.enable-javascript.com/"
              rel="noopener"
              target="_blank"
              >here</a
            >
          </p>
          <label for="js-hide">Close</label>
        </div>
      </div>
      <!-- /JS Warning -->
    </noscript>

    <!-- Send token to JS -->
    <div id="enableTimer" hidden></div>
    <div class="wrapper">
      <header class="main-header">
        <!-- Logo -->
        <a href="index.php" class="logo">
          <!-- mini logo for sidebar mini 50x50 pixels -->
          <span class="logo-mini">P<strong>h</strong></span>
          <!-- logo for regular state and mobile devices -->
          <span class="logo-lg">Pi-<strong>hole</strong></span>
        </a>
        <!-- Header Navbar: style can be found in header.less -->
        <nav class="navbar navbar-static-top">
          <!-- Sidebar toggle button-->
          <a
            href="#"
            class="sidebar-toggle-svg"
            data-toggle="push-menu"
            role="button"
          >
            <i aria-hidden="true" class="fa fa-bars"></i>
            <span class="sr-only">Toggle navigation</span>
          </a>
          <div class="navbar-custom-menu">
            <ul class="nav navbar-nav">
              <li id="pihole-diagnosis" class="hidden">
                <a href="messages.php">
                  <i class="fa fa-exclamation-triangle"></i>
                  <span
                    class="label label-warning"
                    id="pihole-diagnosis-count"
                  ></span>
                </a>
              </li>
              <li>
                <p class="navbar-text">
                  <span class="hidden-xs hidden-sm">hostname:</span>
                  <code>raspberrypi</code>
                </p>
              </li>
              <li class="dropdown user user-menu">
                <a
                  href="#"
                  class="dropdown-toggle"
                  data-toggle="dropdown"
                  aria-expanded="false"
                >
                  <img
                    src="img/logo.svg"
                    class="user-image"
                    alt="Pi-hole logo"
                    style="border-radius: 0"
                    width="25"
                    height="25"
                  />
                  <span class="hidden-xs">Pi-hole</span>
                </a>
                <ul class="dropdown-menu">
                  <!-- User image -->
                  <li class="user-header">
                    <img
                      src="img/logo.svg"
                      alt="Pi-hole Logo"
                      style="border: 0"
                      width="90"
                      height="90"
                    />
                    <p>
                      Open Source Ad Blocker
                      <small>Designed For Raspberry Pi</small>
                    </p>
                  </li>
                  <!-- Menu Body -->
                  <li class="user-body">
                    <div class="row">
                      <div class="col-xs-4 text-center">
                        <a
                          class="btn-link"
                          href="https://github.com/pi-hole"
                          rel="noopener"
                          target="_blank"
                          >GitHub</a
                        >
                      </div>
                      <div class="col-xs-4 text-center">
                        <a
                          class="btn-link"
                          href="https://pi-hole.net/"
                          rel="noopener"
                          target="_blank"
                          >Website</a
                        >
                      </div>
                      <div class="col-xs-4 text-center">
                        <a
                          class="btn-link"
                          href="https://github.com/pi-hole/pi-hole/releases"
                          rel="noopener"
                          target="_blank"
                          >Updates</a
                        >
                      </div>
                      <div id="sessiontimer" class="col-xs-12 text-center">
                        <strong
                          >Session is valid for
                          <span id="sessiontimercounter">0</span></strong
                        >
                      </div>
                    </div>
                  </li>
                  <!-- Menu Footer -->
                  <li class="user-footer">
                    <!-- PayPal -->
                    <div class="text-center">
                      <a
                        href="https://pi-hole.net/donate/"
                        rel="noopener"
                        target="_blank"
                      >
                        <img
                          src="img/donate.gif"
                          alt="Donate"
                          width="147"
                          height="47"
                        />
                      </a>
                    </div>
                  </li>
                </ul>
              </li>
            </ul>
          </div>
        </nav>
      </header>
      <!-- Left side column. contains the logo and sidebar -->
      <aside class="main-sidebar">
        <!-- sidebar: style can be found in sidebar.less -->
        <section class="sidebar">
          <!-- Sidebar user panel -->
          <div class="user-panel">
            <div class="pull-left image">
              <img
                src="img/logo.svg"
                alt="Pi-hole logo"
                width="45"
                height="67"
                style="height: 67px"
              />
            </div>
            <div class="pull-left info">
              <p>Status</p>
              <span id="status"
                ><i class="fa fa-circle missing"></i> Active</span
              ><span id="temperature"
                ><i class="fa fa-fire text-vivid-blue"></i> Temp:&nbsp;<span
                  id="rawtempmissing"
                  hidden
                  >48.312</span
                ><span id="tempdisplay"></span
              ></span>
              <br />
              <span title="Detected 4 cores"
                ><i class="fa fa-circle missing"></i>
                Load:&nbsp;&nbsp;0&nbsp;&nbsp;0&nbsp;&nbsp;0</span
              >
              <br />
              >
            </div>
          </div>
          <!-- sidebar menu: : style can be found in sidebar.less -->
          <ul class="sidebar-menu" data-widget="tree">
            <li class="header text-uppercase">Main navigation</li>
            <!-- Home Page -->
            <li class="active">
              <a href="index.php">
                <i class="fa fa-fw fa-home"></i> <span>Dashboard</span>
              </a>
            </li>
            <!-- Login -->
            <li>
              <a href="index.php?login">
                <i class="fa fa-fw fa-user"></i> <span>Login</span>
              </a>
            </li>
            <!-- Donate -->
            <li>
              <a
                href="https://pi-hole.net/donate/"
                rel="noopener"
                target="_blank"
              >
                <i class="fab fa-fw fa-paypal"></i> <span>Donate</span>
              </a>
            </li>
            <!-- Docs -->
            <li>
              <a
                href="https://docs.pi-hole.net/"
                rel="noopener"
                target="_blank"
              >
                <i class="fa fa-fw fa-question-circle"></i>
                <span>Documentation</span>
              </a>
            </li>
          </ul>
        </section>
        <!-- /.sidebar -->
      </aside>
      <!-- Content Wrapper. Contains page content -->
      <div class="content-wrapper">
        <!-- Main content -->
        <section class="content">
          <!-- Sourceing CSS colors from stylesheet to be used in JS code -->
          <span class="queries-permitted"></span>
          <span class="queries-blocked"></span>
          <span class="graphs-grid"></span>
          <span class="graphs-ticks"></span>
          <!-- Small boxes (Stat box) -->
          <div class="row">
            <div class="col-lg-3 col-sm-6">
              <!-- small box -->
              <div
                class="small-box bg-green no-user-select"
                id="total_queries"
                title="only A + AAAA queries"
              >
                <div class="inner">
                  <p>
                    Total queries (<span id="unique_clients">-</span> clients)
                  </p>
                  <h3 class="statistic">
                    <span id="dns_queries_today">---</span>
                  </h3>
                </div>
                <div class="icon">
                  <i class="fas fa-globe-americas"></i>
                </div>
              </div>
            </div>
            <!-- ./col -->
            <div class="col-lg-3 col-sm-6">
              <!-- small box -->
              <div class="small-box bg-aqua no-user-select">
                <div class="inner">
                  <p>Queries Blocked</p>
                  <h3 class="statistic">
                    <span id="queries_blocked_today">---</span>
                  </h3>
                </div>
                <div class="icon">
                  <i class="fas fa-hand-paper"></i>
                </div>
              </div>
            </div>
            <!-- ./col -->
            <div class="col-lg-3 col-sm-6">
              <!-- small box -->
              <div class="small-box bg-yellow no-user-select">
                <div class="inner">
                  <p>Percent Blocked</p>
                  <h3 class="statistic">
                    <span id="percentage_blocked_today">---</span>
                  </h3>
                </div>
                <div class="icon">
                  <i class="fas fa-chart-pie"></i>
                </div>
              </div>
            </div>
            <!-- ./col -->
            <div class="col-lg-3 col-sm-6">
              <!-- small box -->
              <div
                class="small-box bg-red no-user-select"
                title="Blocking list updated 2 days, 14:55 (hh:mm) ago"
              >
                <div class="inner">
                  <p>Domains on Blocklist</p>
                  <h3 class="statistic">
                    <span id="domains_being_blocked">---</span>
                  </h3>
                </div>
                <div class="icon">
                  <i class="fas fa-list-alt"></i>
                </div>
              </div>
            </div>
            <!-- ./col -->
          </div>

          <div class="row">
            <div class="col-md-12">
              <div class="box" id="queries-over-time">
                <div class="box-header with-border">
                  <h3 class="box-title">Total queries over last 24 hours</h3>
                </div>
                <div class="box-body">
                  <div class="chart">
                    <canvas
                      id="queryOverTimeChart"
                      width="800"
                      height="140"
                    ></canvas>
                  </div>
                </div>
                <div class="overlay">
                  <i class="fa fa-sync fa-spin"></i>
                </div>
                <!-- /.box-body -->
              </div>
            </div>
          </div>

          <script src="scripts/pi-hole/js/utils.js?v=1612277927"></script>
          <script src="scripts/pi-hole/js/index.js?v=1612277927"></script>
        </section>
        <!-- /.content -->
      </div>
      <!-- Modal for custom disable time -->
      <div
        class="modal fade"
        id="customDisableModal"
        tabindex="-1"
        role="dialog"
        aria-labelledby="myModalLabel"
      >
        <div class="modal-dialog modal-sm" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <button
                type="button"
                class="close"
                data-dismiss="modal"
                aria-label="Close"
              >
                <span aria-hidden="true">&times;</span>
              </button>
              <h4 class="modal-title" id="myModalLabel">
                Custom disable timeout
              </h4>
            </div>
            <div class="modal-body">
              <div class="input-group">
                <input
                  id="customTimeout"
                  class="form-control"
                  type="number"
                  value="60"
                />
                <div class="input-group-btn" data-toggle="buttons">
                  <label class="btn btn-default">
                    <input id="selSec" type="radio" /> Secs
                  </label>
                  <label id="btnMins" class="btn btn-default active">
                    <input id="selMin" type="radio" /> Mins
                  </label>
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button
                type="button"
                class="btn btn-default"
                data-dismiss="modal"
              >
                Close
              </button>
              <button
                type="button"
                id="pihole-disable-custom"
                class="btn btn-primary"
                data-dismiss="modal"
              >
                Submit
              </button>
            </div>
          </div>
        </div>
      </div>
      <!-- /.content-wrapper -->

      <footer class="main-footer">
        <div class="row row-centered text-center">
          <div class="col-xs-12 col-sm-6">
            <strong
              ><a
                href="https://pi-hole.net/donate/"
                rel="noopener"
                target="_blank"
                ><i class="fa fa-heart text-red"></i> Donate</a
              ></strong
            >
            if you found this useful.
          </div>
        </div>

        <div class="row row-centered text-center version-info">
          <div class="col-xs-12 col-sm-8 col-md-6">
            <ul class="list-inline">
              <li>
                <strong>Pi-hole</strong>
                <a
                  href="https://github.com/pi-hole/pi-hole/releases/v5.2.4"
                  rel="noopener"
                  target="_blank"
                  >v5.2.4</a
                >
                &middot;
                <a
                  class="lookatme"
                  href="https://github.com/pi-hole/pi-hole/releases/latest"
                  rel="noopener"
                  target="_blank"
                  >Update available!</a
                >
              </li>
              <li>
                <strong>Web Interface</strong>
                <a
                  href="https://github.com/pi-hole/AdminLTE/releases/v5.3.2"
                  rel="noopener"
                  target="_blank"
                  >v5.3.2</a
                >
                &middot;
                <a
                  class="lookatme"
                  href="https://github.com/pi-hole/AdminLTE/releases/latest"
                  rel="noopener"
                  target="_blank"
                  >Update available!</a
                >
              </li>
              <li>
                <strong>FTL</strong>
                <a
                  href="https://github.com/pi-hole/FTL/releases/v5.6"
                  rel="noopener"
                  target="_blank"
                  >v5.6</a
                >
                &middot;
                <a
                  class="lookatme"
                  href="https://github.com/pi-hole/FTL/releases/latest"
                  rel="noopener"
                  target="_blank"
                  >Update available!</a
                >
              </li>
            </ul>
          </div>
        </div>
      </footer>
    </div>
    <!-- ./wrapper -->
    <script src="scripts/pi-hole/js/footer.js?v=1612277927"></script>
  </body>
</html>''';
