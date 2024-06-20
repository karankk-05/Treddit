<script lang="ts">
  type Login = {
    email: string;
    passwd: string;
  };
  let loginfo: Login = $state({ email: "", passwd: "" });
  async function login() {
    let out = await fetch("http://127.0.0.1:3000/user/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(loginfo),
    });
    if (out.ok) {
      let resp = await out.json();

      localStorage.setItem("email", loginfo.email);
      localStorage.setItem("token", resp.token);
    }
  }
</script>

<h1>Log In</h1>
<form onsubmit={login}>
  <h3>Email</h3>
  <input type="email" bind:value={loginfo.email} />
  <h3>Password</h3>
  <input type="password" bind:value={loginfo.passwd} />
  <br />
  <input type="submit" value="Log in!" />
</form>
<a href="/auth/register">New User? Register here</a>
