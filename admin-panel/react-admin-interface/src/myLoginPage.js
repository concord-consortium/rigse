// in src/MyLoginPage.js
import * as React from 'react';
import { ThemeProvider } from '@material-ui/styles';
import { Button, Card, Container, makeStyles } from '@material-ui/core';
import { authorizeInPortal} from "./portalAuthProvider"

const useStyles = makeStyles((theme) => ({
  paper: {
    marginTop: theme.spacing(8),
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  }}))


const MyLoginPage = ({ theme }) => {
    const classes = useStyles();
    return (
        <ThemeProvider theme={theme}>
          <Container component="main" maxWidth="xs" height="500px">
            <div className={classes.paper}>
              <Card>
                <Button
                  variant="contained"
                  color="primary"
                  onClick={authorizeInPortal}>
                    Login Through Portal
                </Button>
              </Card>
            </div>
          </Container>
        </ThemeProvider>
    );
};

export default MyLoginPage;
