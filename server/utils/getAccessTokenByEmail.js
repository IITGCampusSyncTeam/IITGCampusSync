// helpers/getAccessTokenByEmail.js
import axios from 'axios';
import User from '../modules/user/user.model.js';// adjust path as needed

const tenant_id=process.env.AZURE_TENANT_ID;

export const getAccessTokenByEmail = async (email) => {
    try {
        const user = await User.findOne({ email }).select('+refreshToken');

        if (!user || !user.refreshToken) {
            throw new Error('User not found or refresh token missing');
        }

        const response = await axios.post(`https://login.microsoftonline.com/${tenant_id}/oauth2/v2.0/token`, new URLSearchParams({
            client_id: process.env.CLIENT_ID,
            client_secret: process.env.CLIENT_SECRET,
            grant_type: 'refresh_token',
            refresh_token: user.refreshToken,
            redirect_uri: process.env.REDIRECT_URI,
            scope: 'https://graph.microsoft.com/.default' // or your custom scopes
        }), {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        });

        return response.data.access_token;

    } catch (error) {
        console.error("Error fetching access token:", error?.response?.data || error.message);
        throw error;
    }
};
