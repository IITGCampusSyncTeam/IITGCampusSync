import EventRegistration from './eventRegistrationModel.js';
import AppError from '../../utils/appError.js';
import catchAsync from '../../utils/catchAsync.js';

// This controller will handle both registering and un-registering (toggling)
export const toggleRsvp = catchAsync(async (req, res, next) => {
  const eventId = req.params.eventId;
  const userId = req.user.id; // Comes from your isAuthenticated middleware

  // Check if a registration already exists
  const existingRegistration = await EventRegistration.findOne({
    event: eventId,
    user: userId,
  });

  if (existingRegistration) {
    // If it exists, user wants to un-RSVP. So, delete it.
    await EventRegistration.findByIdAndDelete(existingRegistration._id);

    res.status(200).json({
      status: 'success',
      message: 'Successfully unregistered from the event.',
      data: {
        rsvpd: false,
      }
    });
  } else {
    // If it doesn't exist, user wants to RSVP. So, create it.
    const newRegistration = await EventRegistration.create({
      event: eventId,
      user: userId,
    });

    res.status(201).json({
      status: 'success',
      message: 'Successfully registered for the event!',
      data: {
        registration: newRegistration,
        rsvpd: true,
      }
    });
  }
});

// A controller to get all users for an event (for organizers)
export const getRegistrationsForEvent = catchAsync(async (req, res, next) => {
    const registrations = await EventRegistration.find({ event: req.params.eventId }).populate('user');
    res.status(200).json({
        status: 'success',
        results: registrations.length,
        data: {
            registrations
        }
    });
});

